using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using DBFixerMigration.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.Json;

namespace DBFixerMigration.Services;

public class RetryTaskManager
{
    private readonly AmazonDatabaseMigrationServiceClient _dmsClient;
    private readonly AppSettings _appSettings;

    public RetryTaskManager(AmazonDatabaseMigrationServiceClient dmsClient, AppSettings appSettings)
    {
        _dmsClient = dmsClient;
        _appSettings = appSettings;
    }

    public async Task<bool> RetryFailedTasksAsync(List<FailedTaskReport> failedTasks, List<ReplicationInstanceTaskInfo> availableInstances)
    {
        if (!failedTasks.Any())
        {
            Console.WriteLine("No failed tasks to retry.");
            return true;
        }

        Console.WriteLine($"Starting retry process for {failedTasks.Count} failed tasks...");

        // Filter instances that can accept more tasks
        var usableInstances = availableInstances.Where(i => i.CanAcceptMoreTasks).ToList();
        if (!usableInstances.Any())
        {
            Console.WriteLine("No replication instances available for retry tasks (all are at capacity).");
            return false;
        }

        Console.WriteLine($"Available instances for retry: {usableInstances.Count}");
        foreach (var instance in usableInstances)
        {
            Console.WriteLine($"  {instance.InstanceIdentifier}: {instance.AvailableTaskSlots} task slots, {instance.AvailableEndpointSlots} endpoint slots");
        }

        // Group failed tasks by database to create consolidated retry tasks
        var tasksByDatabase = failedTasks.GroupBy(t => t.DatabaseName).ToList();
        Console.WriteLine($"Grouped into {tasksByDatabase.Count} database retry tasks");

        var retryResults = new List<(string DatabaseName, bool Success, string Error)>();
        
        for (int attempt = 1; attempt <= _appSettings.RetryFixer.MaxRetryAttempts; attempt++)
        {
            Console.WriteLine($"\n--- Retry Attempt {attempt}/{_appSettings.RetryFixer.MaxRetryAttempts} ---");
            
            var tasksToRetry = tasksByDatabase.Where(g => !retryResults.Any(r => r.DatabaseName == g.Key && r.Success)).ToList();
            
            if (!tasksToRetry.Any())
            {
                Console.WriteLine("All tasks have been successfully retried!");
                break;
            }

            Console.WriteLine($"Retrying {tasksToRetry.Count} database tasks...");

            foreach (var dbGroup in tasksToRetry)
            {
                try
                {
                    var selectedInstance = SelectOptimalInstance(usableInstances);
                    if (selectedInstance == null)
                    {
                        Console.WriteLine($"No available instance for database {dbGroup.Key}. Skipping...");
                        retryResults.Add((dbGroup.Key, false, "No available instance"));
                        continue;
                    }

                    Console.WriteLine($"Retrying database {dbGroup.Key} on instance {selectedInstance.InstanceIdentifier}");
                    
                    var success = await CreateRetryTaskAsync(dbGroup.ToList(), selectedInstance, attempt);
                    
                    retryResults.Add((dbGroup.Key, success, success ? "" : "Retry task failed"));
                    
                    if (success)
                    {
                        // Update instance capacity (rough estimation)
                        selectedInstance.Tasks.Add(new TaskInfo 
                        { 
                            DatabaseName = dbGroup.Key,
                            TaskIdentifier = $"{_appSettings.RetryFixer.RetryTaskPrefix}-{dbGroup.Key}-{attempt}",
                            Status = "running"
                        });
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error retrying database {dbGroup.Key}: {ex.Message}");
                    retryResults.Add((dbGroup.Key, false, ex.Message));
                }
            }

            // Wait between attempts if not the last attempt
            if (attempt < _appSettings.RetryFixer.MaxRetryAttempts)
            {
                var waitMinutes = _appSettings.RetryFixer.RetryDelayMinutes;
                Console.WriteLine($"Waiting {waitMinutes} minutes before next retry attempt...");
                await Task.Delay(TimeSpan.FromMinutes(waitMinutes));
            }
        }

        // Summary
        var successful = retryResults.Count(r => r.Success);
        var failed = retryResults.Count(r => !r.Success);
        
        Console.WriteLine($"\nRetry Summary: {successful} successful, {failed} failed");
        
        if (failed > 0)
        {
            Console.WriteLine("Failed databases:");
            foreach (var failure in retryResults.Where(r => !r.Success))
            {
                Console.WriteLine($"  {failure.DatabaseName}: {failure.Error}");
            }
        }

        return successful > 0;
    }

    private async Task<bool> CreateRetryTaskAsync(List<FailedTaskReport> failedTables, ReplicationInstanceTaskInfo targetInstance, int attempt)
    {
        var databaseName = failedTables.First().DatabaseName;
        var timestamp = DateTime.UtcNow.ToString("yyyyMMddHHmmss");
        
        try
        {
            // Create database migration object
            var dbMigration = new DatabaseMigration(
                databaseName,
                _appSettings.Database.SourceServerName,
                _appSettings.Database.TargetServerName,
                _appSettings.Database.SourceUsername,
                _appSettings.Database.SourcePassword,
                _appSettings.Database.TargetUsername,
                _appSettings.Database.TargetPassword
            );

            // Create endpoints
            string sourceEndpointArn = await CreateRetrySourceEndpoint(dbMigration, attempt, timestamp);
            string targetEndpointArn = await CreateRetryTargetEndpoint(dbMigration, attempt, timestamp);

            // Create table mappings for failed tables
            string tableMappings = CreateTableMappingsForFailedTables(failedTables);

            // Create retry task
            string retryTaskArn = await CreateRetryReplicationTask(
                dbMigration, 
                targetInstance.ReplicationInstanceArn, 
                sourceEndpointArn, 
                targetEndpointArn, 
                tableMappings, 
                attempt, 
                timestamp);

            Console.WriteLine($"Retry task created successfully for database {databaseName}: {retryTaskArn}");
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to create retry task for database {databaseName}: {ex.Message}");
            return false;
        }
    }

    private async Task<string> CreateRetrySourceEndpoint(DatabaseMigration dbMigration, int attempt, string timestamp)
    {
        var request = new CreateEndpointRequest
        {
            EndpointIdentifier = $"{_appSettings.RetryFixer.RetryTaskPrefix}-source-{dbMigration.DatabaseName}-{attempt}-{timestamp}",
            EndpointType = ReplicationEndpointTypeValue.Source,
            EngineName = "sqlserver",
            ServerName = dbMigration.SourceServerName,
            Port = dbMigration.SourcePort,
            DatabaseName = dbMigration.DatabaseName,
            Username = dbMigration.SourceUsername,
            Password = dbMigration.SourcePassword,
        };

        var response = await _dmsClient.CreateEndpointAsync(request);
        Console.WriteLine($"Retry source endpoint created: {response.Endpoint.EndpointIdentifier}");
        return response.Endpoint.EndpointArn;
    }

    private async Task<string> CreateRetryTargetEndpoint(DatabaseMigration dbMigration, int attempt, string timestamp)
    {
        var request = new CreateEndpointRequest
        {
            EndpointIdentifier = $"{_appSettings.RetryFixer.RetryTaskPrefix}-target-{dbMigration.DatabaseName}-{attempt}-{timestamp}",
            EndpointType = ReplicationEndpointTypeValue.Target,
            EngineName = "aurora-postgresql",
            ServerName = dbMigration.TargetServerName,
            Port = dbMigration.TargetPort,
            DatabaseName = dbMigration.DatabaseName,
            Username = dbMigration.TargetUsername,
            Password = dbMigration.TargetPassword,
        };

        var response = await _dmsClient.CreateEndpointAsync(request);
        Console.WriteLine($"Retry target endpoint created: {response.Endpoint.EndpointIdentifier}");
        return response.Endpoint.EndpointArn;
    }

    private string CreateTableMappingsForFailedTables(List<FailedTaskReport> failedTables)
    {
        var rulesJson = new List<string>();
        int ruleId = 1;

        // Add selection rules for each failed table
        foreach (var table in failedTables)
        {
            rulesJson.Add($@"
    {{
      ""rule-type"": ""selection"",
      ""rule-id"": ""{ruleId}"",
      ""rule-name"": ""{ruleId}"",
      ""object-locator"": {{
        ""schema-name"": ""{table.SchemaName}"",
        ""table-name"": ""{table.TableName}""
      }},
      ""rule-action"": ""include""
    }}");
            ruleId++;
        }

        // Add schema transformation rule (dbo to public)
        rulesJson.Add($@"
    {{
      ""rule-type"": ""transformation"",
      ""rule-id"": ""{ruleId}"",
      ""rule-name"": ""rename-schema"",
      ""rule-target"": ""schema"",
      ""object-locator"": {{
        ""schema-name"": ""%dbo""
      }},
      ""rule-action"": ""rename"",
      ""value"": ""public""
    }}");

        var tableMappings = $@"
{{
  ""rules"": [{string.Join(",", rulesJson)}
  ]
}}";

        return tableMappings;
    }

    private async Task<string> CreateRetryReplicationTask(DatabaseMigration dbMigration, string replicationInstanceArn, 
        string sourceEndpointArn, string targetEndpointArn, string tableMappings, int attempt, string timestamp)
    {
        var retryTaskSettings = CreateRetryTaskSettings();

        var request = new CreateReplicationTaskRequest
        {
            ReplicationTaskIdentifier = $"{_appSettings.RetryFixer.RetryTaskPrefix}-{dbMigration.DatabaseName}-{attempt}-{timestamp}",
            SourceEndpointArn = sourceEndpointArn,
            TargetEndpointArn = targetEndpointArn,
            MigrationType = MigrationTypeValue.FullLoad,
            TableMappings = tableMappings,
            ReplicationInstanceArn = replicationInstanceArn,
            ReplicationTaskSettings = retryTaskSettings,
        };

        var response = await _dmsClient.CreateReplicationTaskAsync(request);
        var replicationTaskArn = response.ReplicationTask.ReplicationTaskArn;
        Console.WriteLine($"Retry replication task created: {response.ReplicationTask.ReplicationTaskIdentifier}");

        // Wait until the replication task is ready
        await WaitForTaskToBeReady(replicationTaskArn);

        // Start the migration task
        var startRequest = new StartReplicationTaskRequest
        {
            ReplicationTaskArn = replicationTaskArn,
            StartReplicationTaskType = StartReplicationTaskTypeValue.StartReplication
        };

        await _dmsClient.StartReplicationTaskAsync(startRequest);
        Console.WriteLine($"Retry migration task started: {replicationTaskArn}");

        // We don't wait for completion in this version - the task will run asynchronously
        return replicationTaskArn;
    }

    private string CreateRetryTaskSettings()
    {
        var config = _appSettings.RetryFixer.RetryTaskConfiguration;

        var retryTaskSettings = new
        {
            Logging = new
            {
                EnableLogging = true,
                LogComponents = new[]
                {
                    new { Id = "SOURCE_UNLOAD", Severity = "LOGGER_SEVERITY_DEFAULT" },
                    new { Id = "TARGET_LOAD", Severity = "LOGGER_SEVERITY_DEFAULT" },
                    new { Id = "TASK_MANAGER", Severity = "LOGGER_SEVERITY_DEFAULT" },
                    new { Id = "SOURCE_CAPTURE", Severity = "LOGGER_SEVERITY_DEFAULT" },
                    new { Id = "TARGET_APPLY", Severity = "LOGGER_SEVERITY_DEFAULT" }
                }
            },
            FullLoadSettings = new
            {
                TargetTablePrepMode = config.TargetTablePrepMode,
                MaxFullLoadSubTasks = 12,
                CommitRate = config.CommitRateDuringFullLoad
            },
            TargetMetadata = new
            {
                SupportLobs = true,
                FullLobMode = config.UseFullLobMode,
                LimitedSizeLobMode = !config.UseFullLobMode,
                LobChunkSize = config.LobChunkSizeKb,
                LobMaxSize = config.MaxLobSizeKb,
                InlineLobMaxSize = config.InlineLobMaxSizeKb
            },
            ValidationSettings = new
            {
                EnableValidation = false
            }
        };

        return System.Text.Json.JsonSerializer.Serialize(retryTaskSettings, new System.Text.Json.JsonSerializerOptions 
        { 
            WriteIndented = true 
        });
    }

    private async Task WaitForTaskToBeReady(string replicationTaskArn)
    {
        var maxWaitTime = TimeSpan.FromMinutes(10);
        var startTime = DateTime.UtcNow;

        while (DateTime.UtcNow - startTime < maxWaitTime)
        {
            var describeRequest = new DescribeReplicationTasksRequest
            {
                Filters = new List<Filter>
                {
                    new Filter
                    {
                        Name = "replication-task-arn",
                        Values = new List<string> { replicationTaskArn }
                    }
                }
            };

            var describeResponse = await _dmsClient.DescribeReplicationTasksAsync(describeRequest);
            var taskStatus = describeResponse.ReplicationTasks[0].Status;

            if (taskStatus == "ready")
            {
                Console.WriteLine("Retry replication task is now ready to start.");
                return;
            }
            else if (taskStatus == "failed")
            {
                throw new Exception($"Retry replication task creation failed. Check AWS DMS logs for details.");
            }

            await Task.Delay(_appSettings.Fixer.PollingIntervalSeconds * 1000);
        }

        throw new TimeoutException("Timeout waiting for retry task to be ready");
    }

    private ReplicationInstanceTaskInfo? SelectOptimalInstance(List<ReplicationInstanceTaskInfo> instances)
    {
        // Select instance with most available slots
        return instances
            .Where(i => i.CanAcceptMoreTasks)
            .OrderByDescending(i => i.AvailableTaskSlots)
            .ThenByDescending(i => i.AvailableEndpointSlots)
            .FirstOrDefault();
    }
}