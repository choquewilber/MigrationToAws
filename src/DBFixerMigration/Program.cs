using Amazon;
using Amazon.DatabaseMigrationService;
using Amazon.Runtime;
using Amazon.Runtime.CredentialManagement;
using DBFixerMigration.Models;
using DBFixerMigration.Services;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace DBFixerMigration;

class Program
{
    private static AppSettings _appSettings = null!;
    private static IConfiguration _configuration = null!;
    private static readonly SemaphoreSlim _fileLock = new(1, 1);

    static async Task Main(string[] args)
    {
        Console.WriteLine("=".PadRight(80, '='));
        Console.WriteLine("DB FIXER MIGRATION - AWS DMS Task Analyzer & Retry Manager");
        Console.WriteLine("=".PadRight(80, '='));
        Console.WriteLine();

        try
        {
            // Build configuration
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile("appsettings.Development.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables();

            _configuration = builder.Build();

            // Bind configuration to settings object
            _appSettings = new AppSettings();
            _configuration.Bind(_appSettings);

            // Validate configuration
            if (!ValidateConfiguration())
            {
                Console.WriteLine("Configuration validation failed. Please check your appsettings.json file.");
                return;
            }

            // Initialize logging
            await InitializeLoggingAsync();

            // Create AWS credentials and DMS client
            var credentials = await CreateAwsCredentialsAsync(_appSettings.Aws);
            var region = RegionEndpoint.GetBySystemName(_appSettings.Aws.Region);
            var dmsClient = new AmazonDatabaseMigrationServiceClient(credentials, region);

            Console.WriteLine($"Connected to AWS DMS in region: {_appSettings.Aws.Region}");
            Console.WriteLine($"Analyzing {_appSettings.Aws.ReplicationInstanceArns.Count} replication instances...");
            Console.WriteLine();

            // Initialize services
            var analyzer = new ReplicationInstanceAnalyzer(dmsClient, _appSettings);
            var postScriptExecutor = new PostScriptExecutor(_appSettings);
            var reporter = new FailedTaskReporter(_appSettings);
            var retryManager = new RetryTaskManager(dmsClient, _appSettings);

            var overallTimer = Stopwatch.StartNew();

            // Step 1: Analyze all replication instances
            Console.WriteLine("STEP 1: Analyzing replication instances and their tasks...");
            var instancesInfo = await analyzer.AnalyzeInstancesAsync(_appSettings.Aws.ReplicationInstanceArns);
            
            if (!instancesInfo.Any())
            {
                Console.WriteLine("No replication instances found or accessible.");
                return;
            }

            // Step 2: Process successful tasks (execute post-scripts)
            Console.WriteLine("\nSTEP 2: Processing successful tasks...");
            await ProcessSuccessfulTasks(instancesInfo, postScriptExecutor);

            // Step 3: Generate report of failed tasks
            Console.WriteLine("\nSTEP 3: Analyzing failed tasks...");
            var failedTasks = ExtractFailedTasks(instancesInfo);
            
            if (failedTasks.Any())
            {
                var reportPath = Path.Combine(Directory.GetCurrentDirectory(), 
                    $"{Path.GetFileNameWithoutExtension(_appSettings.Fixer.FailedTasksCsvPath)}_{DateTime.UtcNow:yyyyMMdd_HHmmss}.csv");
                
                await reporter.GenerateFailedTasksReportAsync(failedTasks, reportPath);
                reporter.DisplayFailedTasksSummary(failedTasks);

                // Step 4: Interactive retry process
                if (_appSettings.Fixer.InteractiveMode && _appSettings.RetryFixer.EnableInteractiveRetry)
                {
                    Console.WriteLine("\nSTEP 4: Retry failed tasks...");
                    reporter.DisplayRetryPrompt(failedTasks);
                    
                    var response = Console.ReadLine()?.ToLowerInvariant();
                    if (response is "y" or "yes")
                    {
                        await ProcessRetryTasks(failedTasks, instancesInfo, retryManager);
                    }
                    else
                    {
                        Console.WriteLine("Retry process skipped by user.");
                    }
                }
                else if (!_appSettings.Fixer.InteractiveMode && _appSettings.RetryFixer.EnableInteractiveRetry)
                {
                    Console.WriteLine("\nSTEP 4: Auto-retry failed tasks (non-interactive mode)...");
                    await ProcessRetryTasks(failedTasks, instancesInfo, retryManager);
                }
            }
            else
            {
                Console.WriteLine("No failed tasks found. All migrations appear to be successful!");
            }

            overallTimer.Stop();
            Console.WriteLine($"\nProcess completed in {overallTimer.Elapsed:mm\\:ss}");
            
            // Log final summary
            await LogFinalSummary(instancesInfo, failedTasks.Count, overallTimer.Elapsed);

        }
        catch (Exception ex)
        {
            Console.WriteLine($"Fatal error: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }

        if (_appSettings.Fixer.InteractiveMode)
        {
            Console.WriteLine("\nPress any key to exit...");
            Console.ReadKey();
        }
    }

    static bool ValidateConfiguration()
    {
        var errors = new List<string>();

        if (string.IsNullOrEmpty(_appSettings.Aws.Region))
            errors.Add("AWS Region is required");

        if (!_appSettings.Aws.ReplicationInstanceArns.Any())
            errors.Add("At least one ReplicationInstanceArn is required");

        // Validate authentication settings
        switch (_appSettings.Aws.AuthenticationMethod.ToLowerInvariant())
        {
            case "accesskey":
                if (string.IsNullOrEmpty(_appSettings.Aws.AccessKey) || string.IsNullOrEmpty(_appSettings.Aws.SecretKey))
                    errors.Add("AccessKey and SecretKey are required when using AccessKey authentication");
                break;
            case "sharedcredentialsfile":
                if (string.IsNullOrEmpty(_appSettings.Aws.ProfileName))
                    errors.Add("ProfileName is required when using SharedCredentialsFile authentication");
                break;
            case "iamrole":
                // No additional validation required for IAM role
                break;
            default:
                errors.Add($"Invalid AuthenticationMethod: {_appSettings.Aws.AuthenticationMethod}. Supported methods are: SharedCredentialsFile, AccessKey, IAMRole");
                break;
        }

        if (errors.Any())
        {
            Console.WriteLine("Configuration errors:");
            foreach (var error in errors)
            {
                Console.WriteLine($"  - {error}");
            }
            return false;
        }

        return true;
    }

    static async Task InitializeLoggingAsync()
    {
        if (!_appSettings.LoggingFile.EnableMigrationLogging)
            return;

        var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss");
        var logFileName = $"dbfixer_migration_{timestamp}.{(_appSettings.LoggingFile.LogFileFormat.ToLowerInvariant() == "csv" ? "csv" : "txt")}";
        var logFilePath = Path.Combine(Directory.GetCurrentDirectory(), logFileName);

        _appSettings.LoggingFile.MigrationLogFilePath = logFileName;

        if (_appSettings.LoggingFile.LogFileFormat.ToLowerInvariant() == "csv")
        {
            await File.WriteAllTextAsync(logFilePath, "Timestamp,Operation,Status,Details\n", Encoding.UTF8);
        }
        else
        {
            await File.WriteAllTextAsync(logFilePath, $"DB Fixer Migration Log - Started at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC\n", Encoding.UTF8);
            await File.AppendAllTextAsync(logFilePath, new string('=', 80) + "\n", Encoding.UTF8);
        }

        Console.WriteLine($"Logging initialized: {logFilePath}");
    }

    static async Task<AWSCredentials> CreateAwsCredentialsAsync(AwsSettings awsSettings)
    {
        Console.WriteLine($"Using AWS authentication method: {awsSettings.AuthenticationMethod}");

        return awsSettings.AuthenticationMethod.ToLowerInvariant() switch
        {
            "sharedcredentialsfile" => CreateSharedCredentialsFileCredentials(awsSettings),
            "accesskey" => CreateAccessKeyCredentials(awsSettings),
            "iamrole" => await CreateIamRoleCredentialsAsync(awsSettings),
            _ => throw new ArgumentException($"Unsupported authentication method: {awsSettings.AuthenticationMethod}. Supported methods are: SharedCredentialsFile, AccessKey, IAMRole")
        };
    }

    static AWSCredentials CreateSharedCredentialsFileCredentials(AwsSettings awsSettings)
    {
        if (string.IsNullOrEmpty(awsSettings.ProfileName))
        {
            throw new ArgumentException("ProfileName is required when using SharedCredentialsFile authentication method.");
        }

        var sharedFile = new SharedCredentialsFile();
        if (!sharedFile.TryGetProfile(awsSettings.ProfileName, out var profile))
        {
            throw new ArgumentException($"Unable to find AWS profile '{awsSettings.ProfileName}' in shared credentials file.");
        }

        if (!AWSCredentialsFactory.TryGetAWSCredentials(profile, sharedFile, out var credentials))
        {
            throw new ArgumentException($"Unable to create AWS credentials from profile '{awsSettings.ProfileName}'. Please ensure the profile is correctly configured in the shared credentials file.");
        }

        Console.WriteLine($"Successfully created credentials using shared credentials file with profile: {awsSettings.ProfileName}");
        return credentials;
    }

    static AWSCredentials CreateAccessKeyCredentials(AwsSettings awsSettings)
    {
        if (string.IsNullOrEmpty(awsSettings.AccessKey) || string.IsNullOrEmpty(awsSettings.SecretKey))
        {
            throw new ArgumentException("AccessKey and SecretKey are required when using AccessKey authentication method.");
        }

        Console.WriteLine("Successfully created credentials using Access Key and Secret Key");
        return new BasicAWSCredentials(awsSettings.AccessKey, awsSettings.SecretKey);
    }

    static async Task<AWSCredentials> CreateIamRoleCredentialsAsync(AwsSettings awsSettings)
    {
        try
        {
            // First, try to use the EC2 instance metadata service
            var instanceMetadataCredentials = new InstanceProfileAWSCredentials();

            // Test if we can get credentials (this will throw if not on EC2 or no role assigned)
            await instanceMetadataCredentials.GetCredentialsAsync();

            // Use the EC2 instance profile directly
            Console.WriteLine("Using EC2 instance profile credentials");
            return instanceMetadataCredentials;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                "Unable to create IAM role credentials. Ensure the application is running on an EC2 instance with an IAM role attached, " +
                "or provide a valid RoleArn to assume. Error: " + ex.Message, ex);
        }
    }

    static async Task ProcessSuccessfulTasks(List<ReplicationInstanceTaskInfo> instancesInfo, PostScriptExecutor postScriptExecutor)
    {
        var successfulTasks = instancesInfo
            .SelectMany(i => i.Tasks)
            .Where(t => t.IsCompleted && !t.HasErrors && t.TaskIdentifier != "afid-nonprod")
            .ToList();

        Console.WriteLine($"Found {successfulTasks.Count} successful tasks for post-script execution");

        if (successfulTasks.Any())
        {
            await postScriptExecutor.ExecutePostScriptsForSuccessfulTasksAsync(successfulTasks);
            await LogOperation("POST_SCRIPTS", "Completed", $"Executed post-scripts for {successfulTasks.Count} successful tasks");
        }
    }

    static List<FailedTaskReport> ExtractFailedTasks(List<ReplicationInstanceTaskInfo> instancesInfo)
    {
        var failedTasks = new List<FailedTaskReport>();

        foreach (var instance in instancesInfo)
        {
            foreach (var task in instance.Tasks.Where(t => t.HasErrors && t.TaskIdentifier != "afid-nonprod"))
            {
                // Add task-level failures
                if (task.IsFailed || task.FailedTables.Any())
                {
                    foreach (var failedTable in task.FailedTables)
                    {
                        failedTable.ReplicationInstanceArn = instance.ReplicationInstanceArn;
                        failedTable.TaskArn = task.TaskArn;
                    }
                    
                    failedTasks.AddRange(task.FailedTables);
                }
                else if (!string.IsNullOrEmpty(task.LastFailureMessage))
                {
                    // Add general task failure
                    failedTasks.Add(new FailedTaskReport
                    {
                        DatabaseName = task.DatabaseName,
                        SchemaName = "unknown",
                        TableName = "TASK_LEVEL_ERROR",
                        ErrorDescription = task.LastFailureMessage,
                        TaskArn = task.TaskArn,
                        ReplicationInstanceArn = instance.ReplicationInstanceArn,
                        Status = task.Status,
                        LastUpdated = DateTime.UtcNow
                    });
                }
            }
        }

        return failedTasks.Distinct().ToList();
    }

    static async Task ProcessRetryTasks(List<FailedTaskReport> failedTasks, List<ReplicationInstanceTaskInfo> instancesInfo, RetryTaskManager retryManager)
    {
        // Filter retryable tasks based on whitelist
        var retryableTasks = failedTasks.Where(t => IsTaskRetryable(t)).ToList();

        if (!retryableTasks.Any())
        {
            Console.WriteLine("No retryable tasks found based on current whitelist configuration.");
            await LogOperation("RETRY", "Skipped", "No retryable tasks found");
            return;
        }

        Console.WriteLine($"Processing retry for {retryableTasks.Count} retryable tasks...");
        await LogOperation("RETRY", "Started", $"Starting retry for {retryableTasks.Count} tasks");

        var retrySuccess = await retryManager.RetryFailedTasksAsync(retryableTasks, instancesInfo);
        
        await LogOperation("RETRY", retrySuccess ? "Completed" : "Partial", 
            retrySuccess ? "All retry tasks completed successfully" : "Some retry tasks failed");
    }

    static bool IsTaskRetryable(FailedTaskReport task)
    {
        // Check if task matches whitelist patterns
        foreach (var rule in _appSettings.RetryFixer.TableWhitelist)
        {
            if (MatchesPattern(task.SchemaName, rule.SchemaPattern) &&
                MatchesPattern(task.TableName, rule.TablePattern))
            {
                return true;
            }
        }

        return false;
    }

    static bool MatchesPattern(string value, string pattern)
    {
        if (string.IsNullOrEmpty(value) || string.IsNullOrEmpty(pattern))
            return false;

        // Support wildcards: * becomes .* and ? becomes .
        var regexPattern = "^" + System.Text.RegularExpressions.Regex.Escape(pattern)
            .Replace("\\*", ".*")
            .Replace("\\?", ".") + "$";

        return System.Text.RegularExpressions.Regex.IsMatch(value, regexPattern,
            System.Text.RegularExpressions.RegexOptions.IgnoreCase);
    }

    static async Task LogOperation(string operation, string status, string details)
    {
        if (!_appSettings.LoggingFile.EnableMigrationLogging)
            return;

        await _fileLock.WaitAsync();
        try
        {
            var timestamp = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
            var logEntry = string.Empty;

            if (_appSettings.LoggingFile.LogFileFormat.ToLowerInvariant() == "csv")
            {
                logEntry = $"{timestamp},{operation},{status},\"{details}\"";
            }
            else
            {
                logEntry = $"[{timestamp}] {operation} - {status}: {details}";
            }

            var logFilePath = Path.Combine(Directory.GetCurrentDirectory(), _appSettings.LoggingFile.MigrationLogFilePath);
            await File.AppendAllTextAsync(logFilePath, logEntry + Environment.NewLine, Encoding.UTF8);
        }
        finally
        {
            _fileLock.Release();
        }
    }

    static async Task LogFinalSummary(List<ReplicationInstanceTaskInfo> instancesInfo, int failedTasksCount, TimeSpan duration)
    {
        var totalTasks = instancesInfo.SelectMany(i => i.Tasks).Count();
        var successfulTasks = instancesInfo.SelectMany(i => i.Tasks).Count(t => t.IsCompleted && !t.HasErrors);
        
        var summary = $"Analysis completed: {totalTasks} total tasks, {successfulTasks} successful, {failedTasksCount} failed, Duration: {duration:mm\\:ss}";
        
        Console.WriteLine($"\nFinal Summary: {summary}");
        await LogOperation("SUMMARY", "Completed", summary);
    }
}