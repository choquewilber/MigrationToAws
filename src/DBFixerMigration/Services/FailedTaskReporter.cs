using DBFixerMigration.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace DBFixerMigration.Services;

public class FailedTaskReporter
{
    private readonly AppSettings _appSettings;
    private readonly SemaphoreSlim _fileLock = new(1, 1);

    public FailedTaskReporter(AppSettings appSettings)
    {
        _appSettings = appSettings;
    }

    public async Task GenerateFailedTasksReportAsync(List<FailedTaskReport> failedTasks, string csvPath)
    {
        if (!failedTasks.Any())
        {
            Console.WriteLine("No failed tasks to report.");
            return;
        }

        await _fileLock.WaitAsync();
        try
        {
            var csvContent = new StringBuilder();
            csvContent.AppendLine("Timestamp,DatabaseName,SchemaName,TableName,ErrorDescription,RowsMigrated,TotalRows,TaskArn,ReplicationInstanceArn,Status");

            foreach (var task in failedTasks.OrderBy(t => t.DatabaseName).ThenBy(t => t.TableName))
            {
                var errorEscaped = task.ErrorDescription.Replace("\"", "\"\"");
                csvContent.AppendLine($"{task.LastUpdated:yyyy-MM-dd HH:mm:ss},{task.DatabaseName},{task.SchemaName},{task.TableName},\"{errorEscaped}\",{task.RowsMigrated},{task.TotalRows},{task.TaskArn},{task.ReplicationInstanceArn},{task.Status}");
            }

            await File.WriteAllTextAsync(csvPath, csvContent.ToString(), Encoding.UTF8);
            Console.WriteLine($"Failed tasks report saved to: {csvPath}");
        }
        finally
        {
            _fileLock.Release();
        }
    }

    public async Task<List<FailedTaskReport>> ReadFailedTasksReportAsync(string csvPath)
    {
        var failedTasks = new List<FailedTaskReport>();

        if (!File.Exists(csvPath))
        {
            Console.WriteLine($"Report file not found: {csvPath}");
            return failedTasks;
        }

        try
        {
            var lines = await File.ReadAllLinesAsync(csvPath);
            
            // Skip header
            for (int i = 1; i < lines.Length; i++)
            {
                var line = lines[i];
                if (string.IsNullOrWhiteSpace(line)) continue;

                var parts = ParseCsvLine(line);
                if (parts.Length >= 10)
                {
                    failedTasks.Add(new FailedTaskReport
                    {
                        LastUpdated = DateTime.TryParse(parts[0], out var timestamp) ? timestamp : DateTime.UtcNow,
                        DatabaseName = parts[1],
                        SchemaName = parts[2],
                        TableName = parts[3],
                        ErrorDescription = parts[4],
                        RowsMigrated = long.TryParse(parts[5], out var migrated) ? migrated : 0,
                        TotalRows = long.TryParse(parts[6], out var total) ? total : 0,
                        TaskArn = parts[7],
                        ReplicationInstanceArn = parts[8],
                        Status = parts[9]
                    });
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error reading failed tasks report: {ex.Message}");
        }

        return failedTasks;
    }

    public void DisplayFailedTasksSummary(List<FailedTaskReport> failedTasks)
    {
        if (!failedTasks.Any())
        {
            Console.WriteLine("No failed tasks found.");
            return;
        }

        Console.WriteLine("\n" + new string('=', 80));
        Console.WriteLine("FAILED TASKS SUMMARY");
        Console.WriteLine(new string('=', 80));

        // Group by database
        var groupedByDatabase = failedTasks.GroupBy(t => t.DatabaseName)
            .OrderBy(g => g.Key)
            .ToList();

        Console.WriteLine($"Total failed tasks: {failedTasks.Count} across {groupedByDatabase.Count} databases\n");

        foreach (var dbGroup in groupedByDatabase)
        {
            Console.WriteLine($"Database: {dbGroup.Key}");
            Console.WriteLine($"  Failed tables: {dbGroup.Count()}");
            
            var errorTypes = dbGroup.GroupBy(t => GetErrorType(t.ErrorDescription))
                .OrderByDescending(g => g.Count())
                .ToList();

            foreach (var errorType in errorTypes.Take(3)) // Show top 3 error types
            {
                Console.WriteLine($"    {errorType.Key}: {errorType.Count()} tables");
            }

            // Show some examples
            var examples = dbGroup.Take(3).ToList();
            foreach (var example in examples)
            {
                Console.WriteLine($"    Example: {example.SchemaName}.{example.TableName} - {TruncateString(example.ErrorDescription, 50)}");
            }

            Console.WriteLine();
        }

        // Overall statistics
        Console.WriteLine("Summary by Error Type:");
        var allErrorTypes = failedTasks.GroupBy(t => GetErrorType(t.ErrorDescription))
            .OrderByDescending(g => g.Count())
            .Take(5);

        foreach (var errorType in allErrorTypes)
        {
            Console.WriteLine($"  {errorType.Key}: {errorType.Count()} instances");
        }

        Console.WriteLine("\n" + new string('=', 80));
    }

    public void DisplayRetryPrompt(List<FailedTaskReport> failedTasks)
    {
        if (!_appSettings.RetryFixer.EnableInteractiveRetry)
        {
            return;
        }

        Console.WriteLine("\nRETRY OPTIONS:");
        Console.WriteLine("The following failed tasks can be retried:");
        
        var retryableTasks = failedTasks.Where(IsTaskRetryable).ToList();
        if (!retryableTasks.Any())
        {
            Console.WriteLine("No retryable tasks found based on current whitelist configuration.");
            return;
        }

        var groupedRetryable = retryableTasks.GroupBy(t => t.DatabaseName)
            .OrderBy(g => g.Key)
            .ToList();

        foreach (var dbGroup in groupedRetryable)
        {
            Console.WriteLine($"  {dbGroup.Key}: {dbGroup.Count()} retryable tables");
        }

        Console.WriteLine($"\nTotal retryable tasks: {retryableTasks.Count}");
        Console.WriteLine("\nDo you want to retry these failed tasks? (y/N): ");
    }

    private bool IsTaskRetryable(FailedTaskReport task)
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

    private bool MatchesPattern(string value, string pattern)
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

    private string GetErrorType(string errorDescription)
    {
        if (string.IsNullOrEmpty(errorDescription))
            return "Unknown Error";

        errorDescription = errorDescription.ToLowerInvariant();

        if (errorDescription.Contains("error") || errorDescription.Contains("failed"))
            return "General Error";
        if (errorDescription.Contains("validation"))
            return "Validation Error";
        if (errorDescription.Contains("timeout"))
            return "Timeout Error";
        if (errorDescription.Contains("connection"))
            return "Connection Error";
        if (errorDescription.Contains("permission") || errorDescription.Contains("access"))
            return "Permission Error";

        return "Other Error";
    }

    private string TruncateString(string input, int maxLength)
    {
        if (string.IsNullOrEmpty(input) || input.Length <= maxLength)
            return input;

        return input.Substring(0, maxLength - 3) + "...";
    }

    private string[] ParseCsvLine(string line)
    {
        var result = new List<string>();
        var current = new StringBuilder();
        bool inQuotes = false;

        for (int i = 0; i < line.Length; i++)
        {
            char c = line[i];

            if (c == '"')
            {
                if (inQuotes && i + 1 < line.Length && line[i + 1] == '"')
                {
                    // Escaped quote
                    current.Append('"');
                    i++; // Skip next quote
                }
                else
                {
                    // Toggle quote state
                    inQuotes = !inQuotes;
                }
            }
            else if (c == ',' && !inQuotes)
            {
                result.Add(current.ToString());
                current.Clear();
            }
            else
            {
                current.Append(c);
            }
        }

        result.Add(current.ToString());
        return result.ToArray();
    }
}