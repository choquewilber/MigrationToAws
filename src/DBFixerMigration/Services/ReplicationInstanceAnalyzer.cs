using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using DBFixerMigration.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace DBFixerMigration.Services;

public class ReplicationInstanceAnalyzer
{
    private readonly AmazonDatabaseMigrationServiceClient _dmsClient;
    private readonly AppSettings _appSettings;

    public ReplicationInstanceAnalyzer(AmazonDatabaseMigrationServiceClient dmsClient, AppSettings appSettings)
    {
        _dmsClient = dmsClient;
        _appSettings = appSettings;
    }

    public async Task<List<ReplicationInstanceTaskInfo>> AnalyzeInstancesAsync(List<string> instanceArns)
    {
        Console.WriteLine($"Analyzing {instanceArns.Count} replication instances...");
        var instancesInfo = new List<ReplicationInstanceTaskInfo>();

        foreach (var instanceArn in instanceArns)
        {
            try
            {
                Console.WriteLine($"Analyzing instance: {instanceArn}");
                var instanceInfo = await AnalyzeSingleInstanceAsync(instanceArn);
                instancesInfo.Add(instanceInfo);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error analyzing instance {instanceArn}: {ex.Message}");
                // Continue with other instances
            }
        }

        return instancesInfo;
    }

    public async Task<ReplicationInstanceTaskInfo> AnalyzeSingleInstanceAsync(string instanceArn)
    {
        var instanceInfo = new ReplicationInstanceTaskInfo
        {
            ReplicationInstanceArn = instanceArn,
            InstanceIdentifier = await GetInstanceIdentifierFromArn(instanceArn)
        };

        var tasks = await GetInstanceTasksAsync(instanceArn);
        instanceInfo.Tasks = tasks;

        Console.WriteLine($"Instance {instanceInfo.InstanceIdentifier}: {tasks.Count} tasks ({instanceInfo.CurrentTaskCount}/50 tasks, {instanceInfo.CurrentEndpointCount}/100 endpoints)");

        return instanceInfo;
    }

    public async Task<List<TaskInfo>> GetInstanceTasksAsync(string instanceArn)
    {
        try
        {
            var request = new DescribeReplicationTasksRequest
            {
                Filters = new List<Filter>
                {
                    new Filter
                    {
                        Name = "replication-instance-arn",
                        Values = new List<string> { instanceArn }
                    }
                }
            };

            var response = await _dmsClient.DescribeReplicationTasksAsync(request);
            var tasks = new List<TaskInfo>();

            foreach (var task in response.ReplicationTasks)
            {
                var taskInfo = await AnalyzeTaskAsync(task);
                tasks.Add(taskInfo);
            }

            return tasks;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error getting tasks for instance {instanceArn}: {ex.Message}");
            return new List<TaskInfo>();
        }
    }

    public async Task<TaskInfo> AnalyzeTaskAsync(ReplicationTask task)
    {
        var taskInfo = new TaskInfo
        {
            TaskArn = task.ReplicationTaskArn,
            TaskIdentifier = task.ReplicationTaskIdentifier,
            DatabaseName = ExtractDatabaseNameFromTask(task),
            Status = task.Status,
            StartTime = task.ReplicationTaskStartDate,
            StopTime = task.ReplicationTaskStats?.StopDate,
            FullLoadProgressPercent = task.ReplicationTaskStats?.FullLoadProgressPercent,
            LastFailureMessage = task.LastFailureMessage
        };

        // Determine if task has errors
        taskInfo.HasErrors = taskInfo.IsFailed || !string.IsNullOrEmpty(taskInfo.LastFailureMessage);

        // If task has potential issues, get detailed table statistics
        if (taskInfo.HasErrors || taskInfo.Status.ToLowerInvariant() == "stopped")
        {
            taskInfo.FailedTables = await GetFailedTablesAsync(task.ReplicationTaskArn, taskInfo.DatabaseName);
            if (taskInfo.FailedTables.Any())
            {
                taskInfo.HasErrors = true;
            }
        }

        return taskInfo;
    }

    public async Task<List<FailedTaskReport>> GetFailedTablesAsync(string taskArn, string databaseName)
    {
        try
        {
            var request = new DescribeTableStatisticsRequest
            {
                ReplicationTaskArn = taskArn,
                MaxRecords = 130
            };

            var response = await _dmsClient.DescribeTableStatisticsAsync(request);
            var failedTables = new List<FailedTaskReport>();

            foreach (var tableStat in response.TableStatistics)
            {
                var hasErrors = tableStat.TableState?.ToLowerInvariant() is "error" or "failed" or "table error" ||
                               tableStat.ValidationState?.ToLowerInvariant() is "error" or "failed" ||
                               tableStat.ValidationFailedRecords > 0;

                if (hasErrors)
                {
                    failedTables.Add(new FailedTaskReport
                    {
                        DatabaseName = databaseName,
                        SchemaName = tableStat.SchemaName ?? "dbo",
                        TableName = tableStat.TableName ?? "unknown",
                        ErrorDescription = $"State: {tableStat.TableState}, Validation: {tableStat.ValidationState}, Failed Records: {tableStat.ValidationFailedRecords}",
                        RowsMigrated = tableStat.FullLoadRows,                        
                        TaskArn = taskArn,
                        Status = tableStat.TableState ?? "unknown",
                        LastUpdated = DateTime.UtcNow
                    });
                }
            }

            return failedTables;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error getting table statistics for task {taskArn}: {ex.Message}");
            return new List<FailedTaskReport>();
        }
    }

    private async Task<string> GetInstanceIdentifierFromArn(string instanceArn)
    {
        try
        {
            var request = new DescribeReplicationInstancesRequest
            {
                Filters = new List<Filter>
                {
                    new Filter
                    {
                        Name = "replication-instance-arn",
                        Values = new List<string> { instanceArn }
                    }
                }
            };

            var response = await _dmsClient.DescribeReplicationInstancesAsync(request);
            return response.ReplicationInstances.FirstOrDefault()?.ReplicationInstanceIdentifier ?? "unknown";
        }
        catch
        {
            return "unknown";
        }
    }

    private string ExtractDatabaseNameFromTask(ReplicationTask task)
    {
        try
        {
            // Try to extract database name from task identifier
            var identifier = task.ReplicationTaskIdentifier;
            
            // Common patterns: migration-task-{dbname}, migration13-task-{dbname}
            if (identifier.Contains("task-"))
            {
                var parts = identifier.Split("task-", StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length > 1)
                {
                    return parts[1];
                }
            }

            // Fallback: try to parse from table mappings JSON
            if (!string.IsNullOrEmpty(task.TableMappings))
            {
                try
                {
                    var tableMappings = JsonSerializer.Deserialize<JsonElement>(task.TableMappings);
                    // This would require more complex parsing based on your table mapping structure
                }
                catch
                {
                    // Ignore JSON parsing errors
                }
            }

            return identifier; // Return the full identifier if we can't extract database name
        }
        catch
        {
            return task.ReplicationTaskIdentifier ?? "unknown";
        }
    }
}