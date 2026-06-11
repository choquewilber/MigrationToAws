using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using DBMigrator.Models;
using System.Text.RegularExpressions;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace DBMigrator;

public class TableRetryManager
{
    private readonly AmazonDatabaseMigrationServiceClient _dmsClient;
    private readonly RetrySettings _retrySettings;
    private readonly AppSettings _appSettings;

    public TableRetryManager(AmazonDatabaseMigrationServiceClient dmsClient, RetrySettings retrySettings, AppSettings appSettings)
    {
        _dmsClient = dmsClient;
        _retrySettings = retrySettings;
        _appSettings = appSettings;
    }

    public async Task<bool> CheckForFailedTablesAndRetry(string replicationTaskArn, DatabaseMigration dbMigration, string replicationInstanceArn)
    {
        if (!_retrySettings.EnableRetryOnFailedTables || _retrySettings.TableWhitelist.Count == 0)
        {
            return false;
        }

        Console.WriteLine($"Checking for failed tables in task: {replicationTaskArn}");

        // Get table statistics for the replication task
        var tableStats = await GetTableStatisticsAsync(replicationTaskArn);
        
        if (tableStats == null || tableStats.Count == 0)
        {
            Console.WriteLine("No table statistics found for the task");
            return false;
        }

        // Find failed tables that match our whitelist
        var failedWhitelistTables = FindFailedWhitelistTables(tableStats);
        
        if (failedWhitelistTables.Count == 0)
        {
            Console.WriteLine("No whitelisted tables found with failures");
            return false;
        }

        Console.WriteLine($"Found {failedWhitelistTables.Count} whitelisted tables with failures:");
        foreach (var table in failedWhitelistTables)
        {
            Console.WriteLine($"  - {table.SchemaName}.{table.TableName} (State: {table.TableState})");
        }

        // Attempt to retry the failed tables
        return await RetryFailedTables(failedWhitelistTables, dbMigration, replicationInstanceArn);
    }

    private async Task<List<TableStatistics>> GetTableStatisticsAsync(string replicationTaskArn)
    {
        try
        {
            var request = new DescribeTableStatisticsRequest
            {
                ReplicationTaskArn = replicationTaskArn,
                MaxRecords = 130
            };

            var response = await _dmsClient.DescribeTableStatisticsAsync(request);
            return response.TableStatistics;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error getting table statistics: {ex.Message}");
            return new List<TableStatistics>();
        }
    }

    private List<TableStatistics> FindFailedWhitelistTables(List<TableStatistics> tableStats)
    {
        var failedWhitelistTables = new List<TableStatistics>();

        // Consider tables as failed if they are in error state or have validation failures
        var failedTables = tableStats.Where(t => 
            t.TableState?.ToLowerInvariant() == "error" ||
            t.TableState?.ToLowerInvariant() == "failed" ||
            t.TableState?.ToLowerInvariant() == "table error" ||
            t.ValidationState?.ToLowerInvariant() == "error" ||
            t.ValidationState?.ToLowerInvariant() == "failed" ||
            t.ValidationFailedRecords > 0).ToList();

        foreach (var failedTable in failedTables)
        {
            // Check if this table matches any of our whitelist patterns
            foreach (var whitelistRule in _retrySettings.TableWhitelist)
            {
                if (MatchesPattern(failedTable.SchemaName, whitelistRule.SchemaPattern) &&
                    MatchesPattern(failedTable.TableName, whitelistRule.TablePattern))
                {
                    failedWhitelistTables.Add(failedTable);
                    break; // Avoid adding the same table multiple times
                }
            }
        }

        return failedWhitelistTables;
    }

    private bool MatchesPattern(string value, string pattern)
    {
        if (string.IsNullOrEmpty(value) || string.IsNullOrEmpty(pattern))
            return false;

        // Support wildcards: * becomes .* and ? becomes .
        var regexPattern = "^" + Regex.Escape(pattern).Replace("\\*", ".*").Replace("\\?", ".") + "$";
        return Regex.IsMatch(value, regexPattern, RegexOptions.IgnoreCase);
    }

    private async Task<bool> RetryFailedTables(List<TableStatistics> failedTables, DatabaseMigration dbMigration, string replicationInstanceArn)
    {
        bool retrySuccess = false;
        
        for (int attempt = 1; attempt <= _retrySettings.MaxRetryAttempts; attempt++)
        {
            Console.WriteLine($"Retry attempt {attempt}/{_retrySettings.MaxRetryAttempts} for {failedTables.Count} tables");

            try
            {
                // Create new endpoints for the retry task
                string sourceEndpointArn = await CreateRetrySourceEndpoint(dbMigration, attempt);
                string targetEndpointArn = await CreateRetryTargetEndpoint(dbMigration, attempt);

                // Create table mappings specifically for the failed tables
                string tableMappings = CreateTableMappingsForFailedTables(failedTables);

                // Create and run the retry task
                string retryTaskArn = await CreateRetryTask(dbMigration, replicationInstanceArn, sourceEndpointArn, targetEndpointArn, tableMappings, attempt);
                
                // Wait for the retry task to complete
                bool taskSucceeded = await WaitForRetryTaskCompletion(retryTaskArn);

                if (taskSucceeded)
                {
                    Console.WriteLine($"Retry attempt {attempt} completed successfully");
                    retrySuccess = true;
                    break;
                }
                else
                {
                    Console.WriteLine($"Retry attempt {attempt} failed");
                    
                    // Wait before next attempt (if not the last attempt)
                    if (attempt < _retrySettings.MaxRetryAttempts)
                    {
                        Console.WriteLine($"Waiting {_retrySettings.RetryDelayMinutes} minutes before next retry attempt...");
                        await Task.Delay(TimeSpan.FromMinutes(_retrySettings.RetryDelayMinutes));
                    }
                }

                // Clean up endpoints
                await CleanupEndpoints(sourceEndpointArn, targetEndpointArn);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error during retry attempt {attempt}: {ex.Message}");
                
                // Wait before next attempt (if not the last attempt)
                if (attempt < _retrySettings.MaxRetryAttempts)
                {
                    Console.WriteLine($"Waiting {_retrySettings.RetryDelayMinutes} minutes before next retry attempt...");
                    await Task.Delay(TimeSpan.FromMinutes(_retrySettings.RetryDelayMinutes));
                }
            }
        }

        return retrySuccess;
    }

    private async Task<string> CreateRetrySourceEndpoint(DatabaseMigration dbMigration, int attempt)
    {
        var request = new CreateEndpointRequest
        {
            EndpointIdentifier = $"retry-source-{dbMigration.DatabaseName}-attempt{attempt}-{DateTime.UtcNow:yyyyMMddHHmmss}",
            EndpointType = ReplicationEndpointTypeValue.Source,
            EngineName = "sqlserver",
            ServerName = dbMigration.SourceServerName,
            Port = dbMigration.SourcePort,
            DatabaseName = dbMigration.DatabaseName,
            Username = dbMigration.SourceUsername,
            Password = dbMigration.SourcePassword,
        };

        var response = await _dmsClient.CreateEndpointAsync(request);
        Console.WriteLine($"Retry source endpoint created with ARN: {response.Endpoint.EndpointArn}");
        return response.Endpoint.EndpointArn;
    }

    private async Task<string> CreateRetryTargetEndpoint(DatabaseMigration dbMigration, int attempt)
    {
        var request = new CreateEndpointRequest
        {
            EndpointIdentifier = $"retry-target-{dbMigration.DatabaseName}-attempt{attempt}-{DateTime.UtcNow:yyyyMMddHHmmss}",
            EndpointType = ReplicationEndpointTypeValue.Target,
            EngineName = "aurora-postgresql",
            ServerName = dbMigration.TargetServerName,
            Port = dbMigration.TargetPort,
            DatabaseName = dbMigration.DatabaseName,
            Username = dbMigration.TargetUsername,
            Password = dbMigration.TargetPassword,
        };

        var response = await _dmsClient.CreateEndpointAsync(request);
        Console.WriteLine($"Retry target endpoint created with ARN: {response.Endpoint.EndpointArn}");
        return response.Endpoint.EndpointArn;
    }

    private string CreateTableMappingsForFailedTables(List<TableStatistics> failedTables)
    {
        var rules = new List<object>();
        int ruleId = 1;

        // Add selection rules for each failed table
        foreach (var table in failedTables)
        {
            rules.Add(new
            {
                rule_type = "selection",
                rule_id = ruleId.ToString(),
                rule_name = ruleId.ToString(),
                object_locator = new
                {
                    schema_name = table.SchemaName,
                    table_name = table.TableName
                },
                rule_action = "include"
            });
            ruleId++;
        }

        // Add schema transformation rule (dbo to public)
        rules.Add(new
        {
            rule_type = "transformation",
            rule_id = ruleId.ToString(),
            rule_name = "rename-schema",
            rule_target = "schema",
            object_locator = new
            {
                schema_name = "%dbo"
            },
            rule_action = "rename",
            value = "public"
        });

        var tableMappings = new
        {
            rules = rules
        };

        return System.Text.Json.JsonSerializer.Serialize(tableMappings, new System.Text.Json.JsonSerializerOptions 
        { 
            WriteIndented = true 
        });
    }

    private async Task<string> CreateRetryTask(DatabaseMigration dbMigration, string replicationInstanceArn, string sourceEndpointArn, string targetEndpointArn, string tableMappings, int attempt)
    {
        var retryTaskSettings = CreateRetryTaskSettings();

        var request = new CreateReplicationTaskRequest
        {
            ReplicationTaskIdentifier = $"retry-task-{dbMigration.DatabaseName}-attempt{attempt}-{DateTime.UtcNow:yyyyMMddHHmmss}",
            SourceEndpointArn = sourceEndpointArn,
            TargetEndpointArn = targetEndpointArn,
            MigrationType = MigrationTypeValue.FullLoad,
            TableMappings = tableMappings,
            ReplicationInstanceArn = replicationInstanceArn,
            ReplicationTaskSettings = retryTaskSettings,
        };

        var response = await _dmsClient.CreateReplicationTaskAsync(request);
        var replicationTaskArn = response.ReplicationTask.ReplicationTaskArn;
        Console.WriteLine($"Retry migration task created with ARN: {replicationTaskArn}");

        // Wait until the replication task is in 'ready' state
        await WaitForTaskToBeReady(replicationTaskArn);

        // Start the migration task
        var startRequest = new StartReplicationTaskRequest
        {
            ReplicationTaskArn = replicationTaskArn,
            StartReplicationTaskType = StartReplicationTaskTypeValue.StartReplication
        };

        await _dmsClient.StartReplicationTaskAsync(startRequest);
        Console.WriteLine($"Retry migration task started: {replicationTaskArn}");

        return replicationTaskArn;
    }

    private string CreateRetryTaskSettings()
    {
        var config = _retrySettings.RetryTaskConfiguration;

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
                TargetTablePrepMode = config.TargetTablePrepMode, // ✅ Ahora configurable
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
        while (true)
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

            Console.WriteLine($"Current retry task status: {taskStatus}");

            if (taskStatus == "ready")
            {
                Console.WriteLine("Retry replication task is now ready to start.");
                break;
            }
            else if (taskStatus == "failed")
            {
                throw new Exception($"Retry replication task creation failed. Check AWS DMS logs for details.");
            }

            await Task.Delay(10000);
        }
    }

    private async Task<bool> WaitForRetryTaskCompletion(string replicationTaskArn)
    {
        Console.WriteLine("Waiting for retry task completion...");

        while (true)
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
            var task = describeResponse.ReplicationTasks[0];
            var status = task.Status;

            Console.WriteLine($"Current retry task status: {status}");

            if (status == "stopped" || status == "completed")
            {
                Console.WriteLine($"Retry task completed successfully: {replicationTaskArn}");
                return true;
            }
            else if (status == "failed" || status == "deleting")
            {
                Console.WriteLine($"Retry task failed: {replicationTaskArn}");
                return false;
            }

            await Task.Delay(15000);
        }
    }

    private async Task CleanupEndpoints(string sourceEndpointArn, string targetEndpointArn)
    {
        try
        {
            Console.WriteLine("Cleaning up retry endpoints...");
            
            if (!string.IsNullOrEmpty(sourceEndpointArn))
            {
                await _dmsClient.DeleteEndpointAsync(new DeleteEndpointRequest { EndpointArn = sourceEndpointArn });
                Console.WriteLine($"Deleted retry source endpoint: {sourceEndpointArn}");
            }
            
            if (!string.IsNullOrEmpty(targetEndpointArn))
            {
                await _dmsClient.DeleteEndpointAsync(new DeleteEndpointRequest { EndpointArn = targetEndpointArn });
                Console.WriteLine($"Deleted retry target endpoint: {targetEndpointArn}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error cleaning up endpoints: {ex.Message}");
        }
    }
}