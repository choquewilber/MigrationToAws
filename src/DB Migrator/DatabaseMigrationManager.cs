using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using DBMigrator.Models;

namespace DBMigrator;

public class DatabaseMigrationManager
{
    private readonly AmazonDatabaseMigrationServiceClient _dmsClient;
    private readonly DatabaseMigration _dbMigration;
    private readonly string _subnetGroupIdentifier;
    private readonly List<string> _securityGroupIds;
    private readonly AppSettings _appSettings;

    public DatabaseMigrationManager(AmazonDatabaseMigrationServiceClient dmsClient, DatabaseMigration dbMigration, string subnetGroupIdentifier, List<string> securityGroupIds, AppSettings appSettings)
    {
        _dmsClient = dmsClient;
        _dbMigration = dbMigration;
        _subnetGroupIdentifier = subnetGroupIdentifier;
        _securityGroupIds = securityGroupIds;
        _appSettings = appSettings;
    }

    public async Task MigrateDatabaseAsync(string replicationInstanceArn)
    {
        string sourceEndpointArn = await CreateSourceEndpoint();
        string targetEndpointArn = await CreateTargetEndpoint();
        //string replicationTaskArn = await CreateAndStartMigrationTask(replicationInstanceArn, sourceEndpointArn, targetEndpointArn);
        // Lanza ambos tasks en paralelo
        var mainTask = RunMigrationTask(replicationInstanceArn, sourceEndpointArn, targetEndpointArn, BuildTableMappings_ExcludeSerializedTableRule(), "main");
        var serializedTask = RunMigrationTask(replicationInstanceArn, sourceEndpointArn, targetEndpointArn, BuildTableMappings_OnlySerializedTableRule(), "serialized");

        // Espera que ambos terminen
        await Task.WhenAll(mainTask, serializedTask);

        // After main migration completes, check for failed tables and retry if necessary
        //if (_appSettings.Retry.EnableRetryOnFailedTables)
        //{
        //    await HandleFailedTablesRetry(replicationTaskArn, replicationInstanceArn);
        //}
    }

    private async Task RunMigrationTask(
        string replicationInstanceArn,
        string sourceEndpointArn,
        string targetEndpointArn,
        string tableMappings,
        string suffix)
    {
        string replicationTaskArn = await CreateReplicationTaskAsync(replicationInstanceArn, sourceEndpointArn, targetEndpointArn, tableMappings, suffix);

        await WaitForTaskReadyAsync(replicationTaskArn);

        await StartReplicationTaskAsync(replicationTaskArn);

        await WaitForTaskCompletionAsync(replicationTaskArn);
    }

    private async Task WaitForTaskCompletionAsync(string replicationTaskArn)
    {
        while (true)
        {
            var describeResponse = await _dmsClient.DescribeReplicationTasksAsync(new DescribeReplicationTasksRequest
            {
                Filters = new List<Filter>
                {
                    new Filter { Name = "replication-task-arn", Values = new List<string> { replicationTaskArn } }
                }
            });

            var status = describeResponse.ReplicationTasks[0].Status;
            Console.WriteLine($"Task {replicationTaskArn} status: {status}");

            if (status is "stopped" or "failed" or "deleting" or "completed")
            {
                Console.WriteLine($"Task finished with status {status}: {replicationTaskArn}");
                break;
            }

            await Task.Delay(120000);
        }
    }

    private async Task<string> CreateReplicationTaskAsync(
        string replicationInstanceArn,
        string sourceEndpointArn,
        string targetEndpointArn,
        string tableMappings,
        string suffix)
    {
        var request = new CreateReplicationTaskRequest
        {
            ReplicationTaskIdentifier = $"migration-task-{_dbMigration.DatabaseName}-{suffix}",
            SourceEndpointArn = sourceEndpointArn,
            TargetEndpointArn = targetEndpointArn,
            MigrationType = MigrationTypeValue.FullLoad,
            TableMappings = tableMappings,
            ReplicationInstanceArn = replicationInstanceArn,
            ReplicationTaskSettings = BuildReplicationTaskSettings()
        };

        var response = await _dmsClient.CreateReplicationTaskAsync(request);
        Console.WriteLine($"Replication task created: {response.ReplicationTask.ReplicationTaskArn}");
        return response.ReplicationTask.ReplicationTaskArn;
    }

    private async Task WaitForTaskReadyAsync(string replicationTaskArn)
    {
        while (true)
        {
            var describeResponse = await _dmsClient.DescribeReplicationTasksAsync(new DescribeReplicationTasksRequest
            {
                Filters = new List<Filter>
                {
                    new Filter { Name = "replication-task-arn", Values = new List<string> { replicationTaskArn } }
                }
            });

            var status = describeResponse.ReplicationTasks[0].Status;
            Console.WriteLine($"Task {replicationTaskArn} status: {status}");

            if (status == "ready") break;
            if (status == "failed") throw new Exception($"Task {replicationTaskArn} creation failed.");

            await Task.Delay(120000);
        }
    }

    private async Task StartReplicationTaskAsync(string replicationTaskArn)
    {
        await _dmsClient.StartReplicationTaskAsync(new StartReplicationTaskRequest
        {
            ReplicationTaskArn = replicationTaskArn,
            StartReplicationTaskType = StartReplicationTaskTypeValue.StartReplication
        });

        Console.WriteLine($"Task started: {replicationTaskArn}");
    }

    private string BuildTableMappings_ExcludeSerializedTableRule() => """
    {
      "rules": [
        {
          "rule-type": "selection",
          "rule-id": "1",
          "rule-name": "include-all",
          "object-locator": { "schema-name": "%", "table-name": "%" },
          "rule-action": "include"
        },
        {
          "rule-type": "selection",
          "rule-id": "2",
          "rule-name": "exclude-serialized",
          "object-locator": { "schema-name": "TableRuleRuntime", "table-name": "SerializedTableRule" },
          "rule-action": "exclude"
        },
        {
          "rule-type": "transformation",
          "rule-id": "3",
          "rule-name": "rename-schema",
          "rule-target": "schema",
          "object-locator": { "schema-name": "%dbo" },
          "rule-action": "rename",
          "value": "public"
        }
      ]
    }
    """;

    private string BuildTableMappings_OnlySerializedTableRule() => """
    {
      "rules": [
        {
          "rule-type": "selection",
          "rule-id": "1",
          "rule-name": "include-serialized",
          "object-locator": { "schema-name": "TableRuleRuntime", "table-name": "SerializedTableRule" },
          "rule-action": "include"
        },
        {
          "rule-type": "transformation",
          "rule-id": "2",
          "rule-name": "rename-schema",
          "rule-target": "schema",
          "object-locator": { "schema-name": "%dbo" },
          "rule-action": "rename",
          "value": "public"
        }
      ]
    }
    """;

    private string BuildReplicationTaskSettings() => """
    {
      "Logging": {
        "EnableLogging": true,
        "LogComponents": [
          { "Id": "SOURCE_UNLOAD", "Severity": "LOGGER_SEVERITY_DEFAULT" },
          { "Id": "TARGET_LOAD", "Severity": "LOGGER_SEVERITY_DEFAULT" },
          { "Id": "TASK_MANAGER", "Severity": "LOGGER_SEVERITY_DEFAULT" },
          { "Id": "SOURCE_CAPTURE", "Severity": "LOGGER_SEVERITY_DEFAULT" },
          { "Id": "TARGET_APPLY", "Severity": "LOGGER_SEVERITY_DEFAULT" }
        ]
      },
      "FullLoadSettings": {
        "TargetTablePrepMode": "DO_NOTHING",
        "MaxFullLoadSubTasks": 12
      },
      "TargetMetadata": {
        "SupportLobs": true,
        "FullLobMode": true,
        "LimitedSizeLobMode": false,
        "LobChunkSize": 256,
        "LobMaxSize": 512,
        "InlineLobMaxSize": 64
      },
      "ValidationSettings": { "EnableValidation": false }
    }
    """;

    private async Task HandleFailedTablesRetry(string replicationTaskArn, string replicationInstanceArn)
    {
        try
        {
            Console.WriteLine("Checking for failed tables that require retry...");

            var retryManager = new TableRetryManager(_dmsClient, _appSettings.Retry, _appSettings);
            bool retryPerformed = await retryManager.CheckForFailedTablesAndRetry(replicationTaskArn, _dbMigration, replicationInstanceArn);

            if (retryPerformed)
            {
                Console.WriteLine("Table retry process completed.");
            }
            else
            {
                Console.WriteLine("No retry was necessary or no whitelisted tables found with failures.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error during table retry process: {ex.Message}");
            // Don't throw - we don't want to fail the entire migration due to retry issues
        }
    }

    private async Task<string> CreateSourceEndpoint()
    {
        var request = new CreateEndpointRequest
        {
            EndpointIdentifier = $"source-endpoint4-{_dbMigration.DatabaseName}",
            EndpointType = ReplicationEndpointTypeValue.Source,
            EngineName = "sqlserver",
            ServerName = _dbMigration.SourceServerName,
            Port = _dbMigration.SourcePort,
            DatabaseName = _dbMigration.DatabaseName,
            Username = _dbMigration.SourceUsername,
            Password = _dbMigration.SourcePassword,
        };

        var response = await _dmsClient.CreateEndpointAsync(request);
        Console.WriteLine($"Source endpoint created with ARN: {response.Endpoint.EndpointArn}");
        return response.Endpoint.EndpointArn;
    }

    private async Task<string> CreateTargetEndpoint()
    {
        var request = new CreateEndpointRequest
        {
            EndpointIdentifier = $"targetfinal4-endpoint-{_dbMigration.DatabaseName}",
            EndpointType = ReplicationEndpointTypeValue.Target,
            EngineName = "aurora-postgresql",
            ServerName = _dbMigration.TargetServerName,
            Port = _dbMigration.TargetPort,
            DatabaseName = $"{_dbMigration.DatabaseName}-2",
            Username = _dbMigration.TargetUsername,
            Password = _dbMigration.TargetPassword,
        };

        var response = await _dmsClient.CreateEndpointAsync(request);
        Console.WriteLine($"Target endpoint created with ARN: {response.Endpoint.EndpointArn}");
        return response.Endpoint.EndpointArn;
    }

    private async Task<string> CreateAndStartMigrationTask(string replicationInstanceArn, string sourceEndpointArn, string targetEndpointArn)
    {
        var tableMappings = """
                            {
                              "rules": [
                                {
                                  "rule-type": "selection",
                                  "rule-id": "1",
                                  "rule-name": "1",
                                  "object-locator": {
                                    "schema-name": "%",
                                    "table-name": "%"
                                  },
                                  "rule-action": "include"
                                },
                                {
                                  "rule-type": "transformation",
                                  "rule-id": "2",
                                  "rule-name": "rename-schema",
                                  "rule-target": "schema",
                                  "object-locator": {
                                    "schema-name": "%dbo"
                                  },
                                  "rule-action": "rename",
                                  "value": "public"
                                },
                                {
                                  "rule-type": "selection",
                                  "rule-id": "375489840",
                                  "rule-name": "375489840",
                                  "object-locator": {
                                    "schema-name": "dbo",
                                    "table-name": "%"
                                  },
                                  "rule-action": "include",
                                  "filters": []
                                }
                              ]
                            }
                            """;

        var replicationTaskSettings = """
                                      {
                                        "Logging": {
                                          "EnableLogging": true,
                                          "LogComponents": [
                                            { "Id": "SOURCE_UNLOAD", "Severity": "LOGGER_SEVERITY_DEFAULT" },
                                            { "Id": "TARGET_LOAD", "Severity": "LOGGER_SEVERITY_DEFAULT" },
                                            { "Id": "TASK_MANAGER", "Severity": "LOGGER_SEVERITY_DEFAULT" },
                                            { "Id": "SOURCE_CAPTURE", "Severity": "LOGGER_SEVERITY_DEFAULT" },
                                            { "Id": "TARGET_APPLY", "Severity": "LOGGER_SEVERITY_DEFAULT" }
                                          ]
                                        },
                                        "FullLoadSettings": {
                                          "TargetTablePrepMode": "DO_NOTHING",
                                          "MaxFullLoadSubTasks": 12
                                        },
                                        "TargetMetadata": {
                                            "SupportLobs": true,
                                            "FullLobMode": true,
                                            "LimitedSizeLobMode": false,
                                            "LobChunkSize": 256,
                                            "LobMaxSize": 512,
                                            "InlineLobMaxSize": 64
                                          },
                                        "ValidationSettings": {
                                          "EnableValidation": false
                                        }
                                      }
                                      """;

        // Step 1: Create the migration task
        var request = new CreateReplicationTaskRequest
        {
            ReplicationTaskIdentifier = $"migration13-task-{_dbMigration.DatabaseName}",
            SourceEndpointArn = sourceEndpointArn,
            TargetEndpointArn = targetEndpointArn,
            MigrationType = MigrationTypeValue.FullLoad,
            TableMappings = tableMappings,
            ReplicationInstanceArn = replicationInstanceArn,
            //ReplicationTaskSettings = "{ \"FullLoadSettings\": { \"TargetTablePrepMode\": \"DO_NOTHING\" } }"
            ReplicationTaskSettings = replicationTaskSettings,

        };

        var response = await _dmsClient.CreateReplicationTaskAsync(request);
        var replicationTaskArn = response.ReplicationTask.ReplicationTaskArn;
        Console.WriteLine($"Migration task created with ARN: {replicationTaskArn}");

        // Wait until the replication task is in 'ready' state
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

            Console.WriteLine($"Current task status: {taskStatus}");

            if (taskStatus == "ready")
            {
                Console.WriteLine("Replication task is now ready to start.");
                break;
            }
            else if (taskStatus == "failed")
            {
                throw new Exception($"Replication task creation failed. Check AWS DMS logs for details.");
            }

            await Task.Delay(10000);
        }

        // Step 2: Start the migration task
        var startRequest = new StartReplicationTaskRequest
        {
            ReplicationTaskArn = replicationTaskArn,
            StartReplicationTaskType = StartReplicationTaskTypeValue.StartReplication
        };

        await _dmsClient.StartReplicationTaskAsync(startRequest);
        Console.WriteLine($"Migration task started: {replicationTaskArn}");

        // Step 3: Wait until the migration task is completed
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

            Console.WriteLine($"Current migration task status: {status}");

            if (status == "stopped" || status == "failed" || status == "deleting" || status == "completed")
            {
                Console.WriteLine($"Migration task {status}: {replicationTaskArn}");
                if (status == "failed")
                {
                    // Don't throw immediately - let the retry logic handle failed tables
                    Console.WriteLine("Migration task failed, but will check for partial failures that can be retried.");
                }
                break;
            }

            await Task.Delay(15000);
        }

        return replicationTaskArn;
    }
}