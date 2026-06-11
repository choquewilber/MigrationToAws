using Amazon;
using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using Amazon.Runtime;
using Amazon.Runtime.CredentialManagement;
using DBMigrator.Models;
using Npgsql;
using System.Diagnostics;
using Microsoft.Extensions.Configuration;
using System.Text;

namespace DBMigrator;

class Program
{
    private static AppSettings _appSettings = null!;
    private static IConfiguration _configuration = null!;
    private static readonly SemaphoreSlim _fileLock = new SemaphoreSlim(1, 1);

    static async Task Main(string[] args)
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

        // Initialize migration log file
        await InitializeMigrationLogFile();

        var databases = await new DatabaseProvider().GetDatabasesAsync();

        if (_appSettings.Database.UseFilterDatabase)
        {
            databases = databases.Where(_appSettings.Database.DatabasesToInclude.Contains).ToList();

            var exclude = new List<string>()
            {
                "3c6fb1f8f7b84e0c8cd79d2fc13c706d",
                "006ca621c4674223a2911a824cc460e1",
                "248c637cb98a424db2b8e80fc98698a9",
                "51572e3d0cf04339ac91009431953c60",
                "bfe05c32d1914695a0f69f4cb272e945",
                "dd562df5be4a406fad1b18374bf21be0",
                "e0df2641f9184158a7e74be324524e92",
                "e3c4a3b9d3ab47a4aefc77a755081aeb",
                "ee8e9ccca436480a91d1284fe192adb6",
                "f6ce7105f4704a51914a675c2e099a54"
            };

            databases = databases.Where(x => !exclude.Contains(x)).ToList();
        }

        var databasesToMigrate = databases.Select(dbName =>
            new DatabaseMigration(dbName, _appSettings.Database.SourceServerName, _appSettings.Database.TargetServerName, _appSettings.Database.SourceUsername, _appSettings.Database.SourcePassword,_appSettings.Database.TargetUsername, _appSettings.Database.TargetPassword)
            {
                DatabaseName = dbName,
            }).ToList();

        // Create AWS credentials based on the authentication method
        var credentials = await CreateAwsCredentialsAsync(_appSettings.Aws);
        
        var region = RegionEndpoint.GetBySystemName(_appSettings.Aws.Region);
        var dmsClient = new AmazonDatabaseMigrationServiceClient(credentials, region);

        string replicationInstanceArn;
        if (_appSettings.Aws.CreateNewReplicationInstance)
        {
            replicationInstanceArn = await CreateReplicationInstance(dmsClient, _appSettings.Aws.SubnetGroupIdentifier, _appSettings.Aws.SecurityGroupIds);
        }
        else
        {
            replicationInstanceArn = _appSettings.Aws.ExistingReplicationInstanceArn;
            Console.WriteLine("Using existing replication instance: " + replicationInstanceArn);
        }

        var batchTimer = Stopwatch.StartNew();
        Console.WriteLine($"Starting batch database migration for {databasesToMigrate.Count} databases");

        // Log batch start
        await LogMigrationStatus("BATCH_START", "Batch Migration Started", 
            $"Starting migration of {databasesToMigrate.Count} databases");

        var batchSize = _appSettings.Migration.BatchSize;
        var totalBatches = (int)Math.Ceiling((double)databasesToMigrate.Count / batchSize);
        
        for (int batchIndex = 0; batchIndex < totalBatches; batchIndex++)
        {
            var batch = databasesToMigrate.Skip(batchIndex * batchSize).Take(batchSize).ToList();
            var batchStartIndex = batchIndex * batchSize + 1;
            var batchEndIndex = Math.Min((batchIndex + 1) * batchSize, databasesToMigrate.Count);
            
            Console.WriteLine($"Processing batch {batchIndex + 1}/{totalBatches}: Databases {batchStartIndex} to {batchEndIndex}");
            
            var batchStopwatch = Stopwatch.StartNew();
            
            var migrationTasks = batch.Select(dbMigration => 
                ProcessSingleDatabaseMigrationAsync(dbMigration, dmsClient, replicationInstanceArn));

            await Task.WhenAll(migrationTasks);
            
            batchStopwatch.Stop();
            Console.WriteLine($"Completed batch {batchIndex + 1}/{totalBatches} in {batchStopwatch.Elapsed:mm\\:ss}");
            
            // Add a small delay between batches to avoid overwhelming the system
            if (batchIndex < totalBatches - 1)
            {
                Console.WriteLine("Waiting 30 seconds before starting next batch...");
                await Task.Delay(30000);
            }
        }

        batchTimer.Stop();
        Console.WriteLine($"All database migrations completed in {batchTimer.Elapsed:mm\\:ss}");
        
        // Log batch completion
        await LogMigrationStatus("BATCH_COMPLETED", "Batch Migration Completed", 
            $"All {databasesToMigrate.Count} databases processed in {batchTimer.Elapsed:mm\\:ss}");
    }

    static async Task InitializeMigrationLogFile()
    {
        if (!_appSettings.LoggingFile.EnableMigrationLogging)
            return;

        var logFilePath = Path.Combine(Directory.GetCurrentDirectory(), _appSettings.LoggingFile.MigrationLogFilePath);
        
        // Add timestamp to filename to make it unique for each run
        var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss");
        var fileExtension = Path.GetExtension(_appSettings.LoggingFile.MigrationLogFilePath);
        var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(_appSettings.LoggingFile.MigrationLogFilePath);
        var uniqueLogFilePath = Path.Combine(Directory.GetCurrentDirectory(), 
            $"{fileNameWithoutExtension}_{timestamp}{fileExtension}");
        
        // Update the settings to use the unique filename
        _appSettings.LoggingFile.MigrationLogFilePath = Path.GetFileName(uniqueLogFilePath);

        if (_appSettings.LoggingFile.LogFileFormat.ToLowerInvariant() == "csv")
        {
            await File.WriteAllTextAsync(uniqueLogFilePath, "Timestamp,DatabaseName,Status,Details\n", Encoding.UTF8);
        }
        else
        {
            await File.WriteAllTextAsync(uniqueLogFilePath, $"Migration Log - Started at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC\n", Encoding.UTF8);
            await File.AppendAllTextAsync(uniqueLogFilePath, new string('=', 80) + "\n", Encoding.UTF8);
        }

        Console.WriteLine($"Migration tracking log file created: {uniqueLogFilePath}");
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
            throw new System.InvalidOperationException(
                "Unable to create IAM role credentials. Ensure the application is running on an EC2 instance with an IAM role attached, " +
                "or provide a valid RoleArn to assume. Error: " + ex.Message, ex);
        }
    }

    static async Task ProcessSingleDatabaseMigrationAsync(DatabaseMigration dbMigration, 
        AmazonDatabaseMigrationServiceClient dmsClient, string replicationInstanceArn)
    {
        Console.WriteLine($"Starting migration for database: {dbMigration.DatabaseName}");
        var dbTimer = Stopwatch.StartNew();
        
        // Log migration start
        await LogMigrationStatus(dbMigration.DatabaseName, "Migration Started", 
            $"Started at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");

        var postMigrationScriptExecuted = false;
        var migrationSuccess = false;

        try
        {
            await CreateDatabaseInPostgresIfNotExists(dbMigration);
            
            // Run pre-migration scripts
            await RunPreMigrationScripts(dbMigration);

            var migrationManager = new DatabaseMigrationManager(dmsClient, dbMigration, _appSettings.Aws.SubnetGroupIdentifier, _appSettings.Aws.SecurityGroupIds, _appSettings);
            await migrationManager.MigrateDatabaseAsync(replicationInstanceArn);

            migrationSuccess = true;
            
            // Log migration completion before running post-migration scripts
            await LogMigrationStatus(dbMigration.DatabaseName, "Migration Completed", 
                $"Data migration completed successfully at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");

            // Run post-migration scripts
            await RunPostMigrationScripts(dbMigration);
            postMigrationScriptExecuted = true;

            // Log post-migration script execution
            await LogMigrationStatus(dbMigration.DatabaseName, "Post-Migration Scripts Executed", 
                $"Post-migration scripts completed at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");

            dbTimer.Stop();
            Console.WriteLine($"Finished migration for {dbMigration.DatabaseName} in {dbTimer.Elapsed:mm\\:ss}");
            
            // Log final success
            await LogMigrationStatus(dbMigration.DatabaseName, "Migration Fully Completed", 
                $"Total migration time: {dbTimer.Elapsed:mm\\:ss}");
        }
        catch (Exception e)
        {
            dbTimer.Stop();
            Console.WriteLine($"Error migrating {dbMigration.DatabaseName} after {dbTimer.Elapsed:mm\\:ss}: {e.Message}");
            
            // Log migration error
            var status = migrationSuccess ? "Post-Migration Script Failed" : "Migration Failed";
            await LogMigrationStatus(dbMigration.DatabaseName, status, 
                $"Error: {e.Message} | Duration: {dbTimer.Elapsed:mm\\:ss} | Post-scripts executed: {postMigrationScriptExecuted}");
        }
    }

    static async Task LogMigrationStatus(string databaseName, string status, string details)
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
                // CSV format: Timestamp,DatabaseName,Status,Details
                logEntry = $"{timestamp},{databaseName},{status},\"{details}\"";
            }
            else
            {
                // TXT format: [Timestamp] DatabaseName - Status: Details
                logEntry = $"[{timestamp}] {databaseName} - {status}: {details}";
            }

            var logFilePath = Path.Combine(Directory.GetCurrentDirectory(), _appSettings.LoggingFile.MigrationLogFilePath);
            
            // Create CSV header if file doesn't exist and format is CSV
            if (!File.Exists(logFilePath) && _appSettings.LoggingFile.LogFileFormat.ToLowerInvariant() == "csv")
            {
                await File.WriteAllTextAsync(logFilePath, "Timestamp,DatabaseName,Status,Details\n", Encoding.UTF8);
            }

            await File.AppendAllTextAsync(logFilePath, logEntry + Environment.NewLine, Encoding.UTF8);
        }
        finally
        {
            _fileLock.Release();
        }
    }

    static async Task RunPreMigrationScripts(DatabaseMigration dbMigration)
    {
        if (dbMigration.DatabaseName.Contains("-changeset"))
        {
            await RunSqlScriptOnPostgres(dbMigration, _appSettings.SqlScripts.ChangesetSchemaScript);
        }
        else if (dbMigration.DatabaseName.Contains("-platform"))
        {
            await RunSqlScriptOnPostgres(dbMigration, _appSettings.SqlScripts.PlatformScript);
        }
        else if (dbMigration.DatabaseName.Contains("changesetPropagation"))
        {
            // No pre-migration script for changeset propagation
        }
        else
        {
            //await RunSqlScriptOnPostgres(dbMigration, _appSettings.SqlScripts.RuntimeScript);
        }
    }

    static async Task RunPostMigrationScripts(DatabaseMigration dbMigration)
    {
        if (dbMigration.DatabaseName.Contains("-changeset"))
        {
            await RunSqlScriptOnPostgres(dbMigration, _appSettings.SqlScripts.ChangesetConstraintScript);
        }
        else if (dbMigration.DatabaseName.Contains("-platform"))
        {
            await RunSqlScriptOnPostgres(dbMigration, _appSettings.SqlScripts.PlatformConstraintsScript);
        }
        else if (dbMigration.DatabaseName.Contains("changesetPropagation"))
        {
            // No post-migration script for changeset propagation
        }
        else
        {
            await RunSqlScriptOnPostgres(dbMigration, _appSettings.SqlScripts.RuntimeConstraintsScript);
        }
    }

    static async Task<string> CreateReplicationInstance(AmazonDatabaseMigrationServiceClient dmsClient,
        string subnetGroupIdentifier, List<string> securityGroupIds)
    {
        var request = new CreateReplicationInstanceRequest
        {
            ReplicationInstanceIdentifier = _appSettings.Aws.ReplicationInstance.Identifier,
            ReplicationInstanceClass = _appSettings.Aws.ReplicationInstance.InstanceClass,
            AllocatedStorage = _appSettings.Aws.ReplicationInstance.AllocatedStorage,
            EngineVersion = _appSettings.Aws.ReplicationInstance.EngineVersion,
            PubliclyAccessible = _appSettings.Aws.ReplicationInstance.PubliclyAccessible,
            VpcSecurityGroupIds = securityGroupIds,
            ReplicationSubnetGroupIdentifier = subnetGroupIdentifier,
            MultiAZ = _appSettings.Aws.ReplicationInstance.MultiAZ
        };

        var response = await dmsClient.CreateReplicationInstanceAsync(request);
        var replicationInstanceArn = response.ReplicationInstance.ReplicationInstanceArn;
        Console.WriteLine(
            $"Replication instance created with ARN: {replicationInstanceArn}. Waiting for it to become active...");

        while (true)
        {
            var describeRequest = new DescribeReplicationInstancesRequest
            {
                Filters =
                [
                    new Filter
                    {
                        Name = "replication-instance-arn", Values = new List<string> { replicationInstanceArn }
                    }
                ]
            };

            var describeResponse = await dmsClient.DescribeReplicationInstancesAsync(describeRequest);
            var instance = describeResponse.ReplicationInstances[0];

            if (instance.ReplicationInstanceStatus == "available")
            {
                Console.WriteLine("Replication instance is now active and available.");
                break;
            }

            Console.WriteLine($"Current status: {instance.ReplicationInstanceStatus}. Waiting...");
            await Task.Delay(_appSettings.Migration.PollingIntervalSeconds * 1000);
        }

        return replicationInstanceArn;
    }

    static async Task CreateDatabaseInPostgresIfNotExists(DatabaseMigration dbMigration)
    {
        var connectionString =
            $"Host={dbMigration.TargetServerName};Username={dbMigration.TargetUsername};Password={dbMigration.TargetPassword};Port={dbMigration.TargetPort};Database=postgres";

        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        var checkDbCommand =
            new NpgsqlCommand($"SELECT 1 FROM pg_database WHERE datname = '{dbMigration.DatabaseName}-2'", connection);
        var exists = await checkDbCommand.ExecuteScalarAsync() != null;

        if (!exists)
        {
            var createDbCommand = new NpgsqlCommand($"CREATE DATABASE \"{dbMigration.DatabaseName}-2\"", connection);
            await createDbCommand.ExecuteNonQueryAsync();
            Console.WriteLine($"Database '{dbMigration.DatabaseName}' created in PostgreSQL.");
        }
        else
        {
            Console.WriteLine($"Database '{dbMigration.DatabaseName}' already exists in PostgreSQL.");
        }
    }

    static async Task RunSqlScriptOnPostgres(DatabaseMigration dbMigration, string scriptFileName)
    {
        var scriptFilePath = Path.Combine(Directory.GetCurrentDirectory(), "Designer",scriptFileName);
        
        if (!File.Exists(scriptFilePath))
        {
            Console.WriteLine($"Warning: SQL script file '{scriptFileName}' not found at '{scriptFilePath}'. Skipping...");
            return;
        }

        var connectionString = $"Host={dbMigration.TargetServerName};Username={dbMigration.TargetUsername};Password={dbMigration.TargetPassword};Port={dbMigration.TargetPort};Database={dbMigration.DatabaseName}-2";

        var sqlScript = await File.ReadAllTextAsync(scriptFilePath);

        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new NpgsqlCommand(sqlScript, connection);
        await command.ExecuteNonQueryAsync();

        Console.WriteLine($"SQL script '{scriptFileName}' executed successfully on database '{dbMigration.DatabaseName}'.");
    }
}