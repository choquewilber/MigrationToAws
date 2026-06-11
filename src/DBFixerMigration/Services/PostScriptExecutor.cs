using DBFixerMigration.Models;
using Npgsql;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace DBFixerMigration.Services;

public class PostScriptExecutor
{
    private readonly AppSettings _appSettings;
    private readonly SemaphoreSlim _fileLock = new(1, 1);

    public PostScriptExecutor(AppSettings appSettings)
    {
        _appSettings = appSettings;
    }

    public async Task ExecutePostScriptsForSuccessfulTasksAsync(List<TaskInfo> successfulTasks)
    {
        if (!_appSettings.Fixer.AutoExecutePostScripts)
        {
            Console.WriteLine("Post-script execution is disabled in configuration.");
            return;
        }

        if (!successfulTasks.Any())
        {
            Console.WriteLine("No successful tasks found for post-script execution.");
            return;
        }

        Console.WriteLine($"Executing post-scripts for {successfulTasks.Count} successful tasks...");

        var scriptResults = new List<(string DatabaseName, string ScriptType, bool Success, string Error)>();

        foreach (var task in successfulTasks)
        {
            try
            {
                Console.WriteLine($"Executing post-script for database: {task.DatabaseName}");
                
                var scriptPath = GetPostScriptForDatabase(task.DatabaseName);
                if (string.IsNullOrEmpty(scriptPath))
                {
                    Console.WriteLine($"No post-script configured for database type: {task.DatabaseName}");
                    continue;
                }

                var success = await ExecutePostScriptAsync(task.DatabaseName, scriptPath);
                var scriptType = GetScriptTypeFromDatabase(task.DatabaseName);
                
                scriptResults.Add((task.DatabaseName, scriptType, success, success ? "" : "Execution failed"));

                if (success)
                {
                    Console.WriteLine($"? Post-script executed successfully for {task.DatabaseName}");
                }
                else
                {
                    Console.WriteLine($"? Post-script execution failed for {task.DatabaseName}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"? Error executing post-script for {task.DatabaseName}: {ex.Message}");
                var scriptType = GetScriptTypeFromDatabase(task.DatabaseName);
                scriptResults.Add((task.DatabaseName, scriptType, false, ex.Message));
            }
        }

        // Log results
        await LogPostScriptResults(scriptResults);
        
        // Summary
        var successful = scriptResults.Count(r => r.Success);
        var failed = scriptResults.Count(r => !r.Success);
        Console.WriteLine($"\nPost-script execution summary: {successful} successful, {failed} failed");
    }

    private string GetPostScriptForDatabase(string databaseName)
    {
        if (databaseName.Contains("-changeset"))
        {
            return _appSettings.SqlScripts.ChangesetConstraintScript;
        }
        else if (databaseName.Contains("-platform"))
        {
            return _appSettings.SqlScripts.PlatformConstraintsScript;
        }
        else if (databaseName.Contains("changesetPropagation"))
        {
            return ""; // No post-script for changeset propagation
        }
        else
        {
            return _appSettings.SqlScripts.RuntimeConstraintsScript;
        }
    }

    private string GetScriptTypeFromDatabase(string databaseName)
    {
        if (databaseName.Contains("-changeset"))
        {
            return "Changeset Constraints";
        }
        else if (databaseName.Contains("-platform"))
        {
            return "Platform Constraints";
        }
        else if (databaseName.Contains("changesetPropagation"))
        {
            return "No Script";
        }
        else
        {
            return "Runtime Constraints";
        }
    }

    private async Task<bool> ExecutePostScriptAsync(string databaseName, string scriptFileName)
    {
        if (string.IsNullOrEmpty(scriptFileName))
        {
            return true; // No script to execute is considered success
        }

        var scriptFilePath = Path.Combine(Directory.GetCurrentDirectory(), "Designer", scriptFileName);
        
        if (!File.Exists(scriptFilePath))
        {
            Console.WriteLine($"Warning: SQL script file '{scriptFileName}' not found at '{scriptFilePath}'. Skipping...");
            return false;
        }

        try
        {
            // Create database migration object to get connection info
            var dbMigration = new DatabaseMigration(
                databaseName,
                _appSettings.Database.SourceServerName,
                _appSettings.Database.TargetServerName,
                _appSettings.Database.SourceUsername,
                _appSettings.Database.SourcePassword,
                _appSettings.Database.TargetUsername,
                _appSettings.Database.TargetPassword
            );

            var connectionString = $"Host={dbMigration.TargetServerName};Username={dbMigration.TargetUsername};Password={dbMigration.TargetPassword};Port={dbMigration.TargetPort};Database={dbMigration.DatabaseName}";

            var sqlScript = await File.ReadAllTextAsync(scriptFilePath);

            await using var connection = new NpgsqlConnection(connectionString);
            await connection.OpenAsync();

            await using var command = new NpgsqlCommand(sqlScript, connection);
            command.CommandTimeout = 300; // 5 minutes timeout for post-scripts

            await command.ExecuteNonQueryAsync();

            Console.WriteLine($"SQL script '{scriptFileName}' executed successfully on database '{databaseName}'.");
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error executing script '{scriptFileName}' on database '{databaseName}': {ex.Message}");
            return false;
        }
    }

    private async Task LogPostScriptResults(List<(string DatabaseName, string ScriptType, bool Success, string Error)> results)
    {
        if (!_appSettings.LoggingFile.EnableMigrationLogging)
            return;

        await _fileLock.WaitAsync();
        try
        {
            var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss");
            var logFileName = $"post_script_execution_{timestamp}.csv";
            var logFilePath = Path.Combine(Directory.GetCurrentDirectory(), logFileName);

            var csvContent = new StringBuilder();
            csvContent.AppendLine("Timestamp,DatabaseName,ScriptType,Status,Error");

            foreach (var result in results)
            {
                var timestampStr = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
                var status = result.Success ? "Success" : "Failed";
                var errorEscaped = result.Error.Replace("\"", "\"\""); // Escape quotes for CSV
                csvContent.AppendLine($"{timestampStr},{result.DatabaseName},{result.ScriptType},{status},\"{errorEscaped}\"");
            }

            await File.WriteAllTextAsync(logFilePath, csvContent.ToString(), Encoding.UTF8);
            Console.WriteLine($"Post-script execution log saved to: {logFilePath}");
        }
        finally
        {
            _fileLock.Release();
        }
    }
}