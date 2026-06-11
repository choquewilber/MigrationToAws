using Amazon;
using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using Amazon.Runtime;
using Amazon.Runtime.CredentialManagement;
using Microsoft.Extensions.Configuration;
using DmsCleanup.Models;
using System.Text;
using InvalidOperationException = System.InvalidOperationException;

namespace DmsCleanup;

class Program
{
    private static AppSettings _appSettings = null!;
    private static IConfiguration _configuration = null!;

    static async Task Main(string[] args)
    {
        Console.WriteLine("AWS DMS Cleanup Tool");
        Console.WriteLine("===================");
        Console.WriteLine();

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

        // Create AWS credentials
        var credentials = await CreateAwsCredentialsAsync(_appSettings.Aws);
        var region = RegionEndpoint.GetBySystemName(_appSettings.Aws.Region);
        var dmsClient = new AmazonDatabaseMigrationServiceClient(credentials, region);

        Console.WriteLine($"Connected to AWS DMS in region: {_appSettings.Aws.Region}");
        Console.WriteLine($"Dry Run Mode: {(_appSettings.Cleanup.DryRun ? "ENABLED" : "DISABLED")}");
        Console.WriteLine($"Cancel Running Tasks: {(_appSettings.Cleanup.CancelRunningTasks ? "ENABLED" : "DISABLED")}");
        Console.WriteLine($"Cleanup Orphaned Endpoints: {(_appSettings.Cleanup.CleanupOrphanedEndpoints ? "ENABLED" : "DISABLED")}");
        Console.WriteLine();

        if (_appSettings.Cleanup.DryRun)
        {
            Console.WriteLine("WARNING: This is a DRY RUN. No resources will be deleted.");
            Console.WriteLine("Set 'Cleanup.DryRun' to false in appsettings.json to actually delete resources.");
            Console.WriteLine();
        }
        else
        {
            Console.WriteLine("WARNING: DRY RUN IS DISABLED. Resources WILL BE DELETED!");
            Console.WriteLine("Press 'Y' to continue or any other key to exit...");
            var key = Console.ReadKey();
            Console.WriteLine();
            if (key.Key != ConsoleKey.Y)
            {
                Console.WriteLine("Operation cancelled by user.");
                return;
            }
            Console.WriteLine();
        }

        // Process each replication instance
        foreach (var replicationInstanceArn in _appSettings.Cleanup.ReplicationInstanceArns)
        {
            await ProcessReplicationInstanceAsync(dmsClient, replicationInstanceArn);
        }

        // Process orphaned endpoints if configured
        if (_appSettings.Cleanup.CleanupOrphanedEndpoints && _appSettings.Cleanup.OrphanedEndpointPrefixes.Count > 0)
        {
            await ProcessOrphanedEndpointsAsync(dmsClient);
        }

        Console.WriteLine();
        Console.WriteLine("DMS cleanup completed!");
    }

    static bool ValidateConfiguration()
    {
        var errors = new List<string>();

        if (string.IsNullOrEmpty(_appSettings.Aws.Region))
        {
            errors.Add("AWS Region is required");
        }

        if (_appSettings.Aws.AuthenticationMethod.ToLowerInvariant() == "accesskey")
        {
            if (string.IsNullOrEmpty(_appSettings.Aws.AccessKey))
            {
                errors.Add("AccessKey is required when using AccessKey authentication");
            }
            if (string.IsNullOrEmpty(_appSettings.Aws.SecretKey))
            {
                errors.Add("SecretKey is required when using AccessKey authentication");
            }
        }

        if (_appSettings.Cleanup.ReplicationInstanceArns.Count == 0)
        {
            errors.Add("At least one ReplicationInstanceArn is required");
        }

        if (errors.Count > 0)
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
            var instanceMetadataCredentials = new InstanceProfileAWSCredentials();
            await instanceMetadataCredentials.GetCredentialsAsync();
            Console.WriteLine("Using EC2 instance profile credentials");
            return instanceMetadataCredentials;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                "Unable to create IAM role credentials. Ensure the application is running on an EC2 instance with an IAM role attached. Error: " + ex.Message, ex);
        }
    }

    static async Task ProcessReplicationInstanceAsync(AmazonDatabaseMigrationServiceClient dmsClient, string replicationInstanceArn)
    {
        Console.WriteLine($"Processing replication instance: {replicationInstanceArn}");
        Console.WriteLine(new string('-', 80));

        try
        {
            // Get all replication tasks for this instance
            var tasks = await GetReplicationTasksForInstanceAsync(dmsClient, replicationInstanceArn);
            
            if (tasks.Count == 0)
            {
                Console.WriteLine("No replication tasks found for this instance.");
                
                // If configured to delete replication instance and no tasks exist, we can proceed with deletion
                if (_appSettings.Cleanup.DeleteReplicationInstance)
                {
                    await DeleteReplicationInstanceAsync(dmsClient, replicationInstanceArn);
                }
                
                Console.WriteLine();
                return;
            }

            Console.WriteLine($"Found {tasks.Count} replication tasks for this instance:");
            foreach (var task in tasks)
            {
                Console.WriteLine($"  - {task.ReplicationTaskIdentifier} (Status: {task.Status})");
            }
            Console.WriteLine();

            // Filter tasks by status
            var tasksToDelete = tasks.Where(t => _appSettings.Cleanup.TaskStatusesToDelete.Contains(t.Status.ToLowerInvariant())).ToList();
            
            // Check for running tasks that need to be cancelled
            var runningTasks = tasks.Where(t => t.Status.ToLowerInvariant() == "running").ToList();
            
            if (runningTasks.Count > 0)
            {
                Console.WriteLine($"Found {runningTasks.Count} running tasks:");
                foreach (var task in runningTasks)
                {
                    Console.WriteLine($"  - {task.ReplicationTaskIdentifier} (Status: {task.Status})");
                }
                Console.WriteLine();
                
                if (_appSettings.Cleanup.CancelRunningTasks)
                {
                    Console.WriteLine("CancelRunningTasks is enabled. Running tasks will be cancelled and added to deletion list.");
                    Console.WriteLine();
                    
                    // Add running tasks to the deletion list
                    foreach (var runningTask in runningTasks)
                    {
                        if (!tasksToDelete.Any(t => t.ReplicationTaskArn == runningTask.ReplicationTaskArn))
                        {
                            tasksToDelete.Add(runningTask);
                        }
                    }
                }
                else
                {
                    Console.WriteLine("CancelRunningTasks is disabled. Running tasks will be skipped.");
                    Console.WriteLine("To cancel and delete running tasks, set 'Cleanup.CancelRunningTasks' to true in appsettings.json");
                    Console.WriteLine();
                }
            }
            
            if (tasksToDelete.Count == 0)
            {
                Console.WriteLine($"No tasks found to delete.");
                if (runningTasks.Count > 0 && !_appSettings.Cleanup.CancelRunningTasks)
                {
                    Console.WriteLine("Note: There are running tasks that could be cancelled if 'CancelRunningTasks' is enabled.");
                }
                Console.WriteLine();
                return;
            }

            Console.WriteLine($"Found {tasksToDelete.Count} tasks to delete:");
            foreach (var task in tasksToDelete)
            {
                Console.WriteLine($"  - {task.ReplicationTaskIdentifier} (Status: {task.Status})");
            }
            Console.WriteLine();

            // Collect endpoints before deleting tasks
            var endpointsToDelete = new HashSet<string>();
            foreach (var task in tasksToDelete)
            {
                if (!string.IsNullOrEmpty(task.SourceEndpointArn))
                {
                    endpointsToDelete.Add(task.SourceEndpointArn);
                }
                if (!string.IsNullOrEmpty(task.TargetEndpointArn))
                {
                    endpointsToDelete.Add(task.TargetEndpointArn);
                }
            }

            // Delete replication tasks
            if (_appSettings.Cleanup.DeleteTasks)
            {
                Console.WriteLine("Deleting replication tasks...");
                foreach (var task in tasksToDelete)
                {
                    await DeleteReplicationTaskAsync(dmsClient, task);
                }
                Console.WriteLine();
            }

            // Delete endpoints
            if (_appSettings.Cleanup.DeleteEndpoints && endpointsToDelete.Count > 0)
            {
                Console.WriteLine($"Found {endpointsToDelete.Count} unique endpoints to delete:");
                foreach (var endpointArn in endpointsToDelete)
                {
                    Console.WriteLine($"  - {endpointArn}");
                }
                Console.WriteLine();

                Console.WriteLine("Deleting endpoints...");
                foreach (var endpointArn in endpointsToDelete)
                {
                    await DeleteEndpointAsync(dmsClient, endpointArn);
                }
                Console.WriteLine();
            }

            // Delete replication instance if configured to do so
            if (_appSettings.Cleanup.DeleteReplicationInstance)
            {
                // Verify that all tasks have been cleaned up before deleting the instance
                var remainingTasks = await GetReplicationTasksForInstanceAsync(dmsClient, replicationInstanceArn);
                if (remainingTasks.Count == 0)
                {
                    await DeleteReplicationInstanceAsync(dmsClient, replicationInstanceArn);
                }
                else
                {
                    Console.WriteLine($"Warning: Cannot delete replication instance {replicationInstanceArn} because {remainingTasks.Count} tasks still exist:");
                    foreach (var task in remainingTasks)
                    {
                        Console.WriteLine($"  - {task.ReplicationTaskIdentifier} (Status: {task.Status})");
                    }
                    Console.WriteLine("Skipping replication instance deletion.");
                }
                Console.WriteLine();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error processing replication instance {replicationInstanceArn}: {ex.Message}");
        }

        Console.WriteLine();
    }

    static async Task<List<ReplicationTask>> GetReplicationTasksForInstanceAsync(AmazonDatabaseMigrationServiceClient dmsClient, string replicationInstanceArn)
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
                        Values = new List<string> { replicationInstanceArn }
                    }
                }
            };

            var response = await dmsClient.DescribeReplicationTasksAsync(request);
            return response.ReplicationTasks;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error getting replication tasks: {ex.Message}");
            return new List<ReplicationTask>();
        }
    }

    static async Task DeleteReplicationTaskAsync(AmazonDatabaseMigrationServiceClient dmsClient, ReplicationTask task)
    {
        try
        {
            if (_appSettings.Cleanup.DryRun)
            {
                if (task.Status.ToLowerInvariant() == "running")
                {
                    Console.WriteLine($"[DRY RUN] Would cancel and delete running replication task: {task.ReplicationTaskIdentifier}");
                }
                else
                {
                    Console.WriteLine($"[DRY RUN] Would delete replication task: {task.ReplicationTaskIdentifier}");
                }
                return;
            }

            // Stop the task if it's running
            if (task.Status.ToLowerInvariant() == "running")
            {
                Console.WriteLine($"Cancelling running replication task: {task.ReplicationTaskIdentifier}");
                var stopRequest = new StopReplicationTaskRequest
                {
                    ReplicationTaskArn = task.ReplicationTaskArn
                };
                await dmsClient.StopReplicationTaskAsync(stopRequest);

                // Wait for task to stop
                Console.WriteLine($"Waiting for task {task.ReplicationTaskIdentifier} to stop...");
                await WaitForTaskStatusAsync(dmsClient, task.ReplicationTaskArn, new[] { "stopped", "failed" });
                Console.WriteLine($"Task {task.ReplicationTaskIdentifier} has been successfully cancelled.");
            }

            Console.WriteLine($"Deleting replication task: {task.ReplicationTaskIdentifier}");
            var deleteRequest = new DeleteReplicationTaskRequest
            {
                ReplicationTaskArn = task.ReplicationTaskArn
            };

            await dmsClient.DeleteReplicationTaskAsync(deleteRequest);
            
            // Wait for task to be fully deleted before continuing
            await WaitForTaskDeletionAsync(dmsClient, task.ReplicationTaskArn, task.ReplicationTaskIdentifier);
            
            Console.WriteLine($"Successfully deleted replication task: {task.ReplicationTaskIdentifier}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error deleting replication task {task.ReplicationTaskIdentifier}: {ex.Message}");
        }
    }

    static async Task DeleteEndpointAsync(AmazonDatabaseMigrationServiceClient dmsClient, string endpointArn)
    {
        try
        {
            if (_appSettings.Cleanup.DryRun)
            {
                Console.WriteLine($"[DRY RUN] Would delete endpoint: {endpointArn}");
                return;
            }

            Console.WriteLine($"Deleting endpoint: {endpointArn}");
            var deleteRequest = new DeleteEndpointRequest
            {
                EndpointArn = endpointArn
            };

            await dmsClient.DeleteEndpointAsync(deleteRequest);
            Console.WriteLine($"Successfully deleted endpoint: {endpointArn}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error deleting endpoint {endpointArn}: {ex.Message}");
        }
    }

    static async Task DeleteReplicationInstanceAsync(AmazonDatabaseMigrationServiceClient dmsClient, string replicationInstanceArn)
    {
        try
        {
            if (_appSettings.Cleanup.DryRun)
            {
                Console.WriteLine($"[DRY RUN] Would delete replication instance: {replicationInstanceArn}");
                return;
            }

            // First, verify the replication instance exists and get its details
            var describeRequest = new DescribeReplicationInstancesRequest
            {
                Filters = new List<Filter>
                {
                    new Filter
                    {
                        Name = "replication-instance-arn",
                        Values = new List<string> { replicationInstanceArn }
                    }
                }
            };

            var describeResponse = await dmsClient.DescribeReplicationInstancesAsync(describeRequest);
            if (describeResponse.ReplicationInstances.Count == 0)
            {
                Console.WriteLine($"Replication instance {replicationInstanceArn} not found. It may have already been deleted.");
                return;
            }

            var replicationInstance = describeResponse.ReplicationInstances[0];
            Console.WriteLine($"Deleting replication instance: {replicationInstance.ReplicationInstanceIdentifier}");

            var deleteRequest = new DeleteReplicationInstanceRequest
            {
                ReplicationInstanceArn = replicationInstanceArn
            };

            await dmsClient.DeleteReplicationInstanceAsync(deleteRequest);
            
            // Wait for replication instance to be fully deleted
            await WaitForReplicationInstanceDeletionAsync(dmsClient, replicationInstanceArn, replicationInstance.ReplicationInstanceIdentifier);
            
            Console.WriteLine($"Successfully deleted replication instance: {replicationInstance.ReplicationInstanceIdentifier}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error deleting replication instance {replicationInstanceArn}: {ex.Message}");
        }
    }

    static async Task WaitForTaskStatusAsync(AmazonDatabaseMigrationServiceClient dmsClient, string taskArn, string[] targetStatuses)
    {
        var maxWaitTime = TimeSpan.FromMinutes(5);
        var startTime = DateTime.UtcNow;

        while (DateTime.UtcNow - startTime < maxWaitTime)
        {
            try
            {
                var request = new DescribeReplicationTasksRequest
                {
                    Filters = new List<Filter>
                    {
                        new Filter
                        {
                            Name = "replication-task-arn",
                            Values = new List<string> { taskArn }
                        }
                    }
                };

                var response = await dmsClient.DescribeReplicationTasksAsync(request);
                if (response.ReplicationTasks.Count > 0)
                {
                    var status = response.ReplicationTasks[0].Status;
                    Console.WriteLine($"Task status: {status}");

                    if (targetStatuses.Contains(status.ToLowerInvariant()))
                    {
                        return;
                    }
                }

                await Task.Delay(_appSettings.Cleanup.PollingIntervalSeconds * 1000);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking task status: {ex.Message}");
                break;
            }
        }
    }

    static async Task WaitForTaskDeletionAsync(AmazonDatabaseMigrationServiceClient dmsClient, string taskArn, string taskIdentifier)
    {
        var maxWaitTime = TimeSpan.FromMinutes(10); // Deletion can take longer than status changes
        var startTime = DateTime.UtcNow;
        
        Console.WriteLine($"Waiting for task {taskIdentifier} to be fully deleted...");

        while (DateTime.UtcNow - startTime < maxWaitTime)
        {
            try
            {
                var request = new DescribeReplicationTasksRequest
                {
                    Filters = new List<Filter>
                    {
                        new Filter
                        {
                            Name = "replication-task-arn",
                            Values = new List<string> { taskArn }
                        }
                    }
                };

                var response = await dmsClient.DescribeReplicationTasksAsync(request);
                
                // If no tasks are returned, the task has been successfully deleted
                if (response.ReplicationTasks.Count == 0)
                {
                    Console.WriteLine($"Task {taskIdentifier} has been fully deleted.");
                    return;
                }

                // Check if task is in 'deleting' status
                var task = response.ReplicationTasks[0];
                var status = task.Status.ToLowerInvariant();
                Console.WriteLine($"Task {taskIdentifier} deletion status: {task.Status}");
                
                // If the task failed to delete, we should stop waiting
                if (status == "failed")
                {
                    Console.WriteLine($"Warning: Task {taskIdentifier} deletion failed. Continuing with cleanup process.");
                    return;
                }

                await Task.Delay(_appSettings.Cleanup.PollingIntervalSeconds * 1000);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking task deletion status: {ex.Message}");
                // If we get an error (like task not found), it might mean it's been deleted
                // Continue with the cleanup process
                return;
            }
        }

        Console.WriteLine($"Warning: Timeout waiting for task {taskIdentifier} to be deleted. Continuing with cleanup process.");
    }

    static async Task WaitForReplicationInstanceDeletionAsync(AmazonDatabaseMigrationServiceClient dmsClient, string instanceArn, string instanceIdentifier)
    {
        var maxWaitTime = TimeSpan.FromMinutes(15); // Replication instance deletion can take longer
        var startTime = DateTime.UtcNow;
        
        Console.WriteLine($"Waiting for replication instance {instanceIdentifier} to be fully deleted...");

        while (DateTime.UtcNow - startTime < maxWaitTime)
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

                var response = await dmsClient.DescribeReplicationInstancesAsync(request);
                
                // If no instances are returned, the instance has been successfully deleted
                if (response.ReplicationInstances.Count == 0)
                {
                    Console.WriteLine($"Replication instance {instanceIdentifier} has been fully deleted.");
                    return;
                }

                // Check if instance is in 'deleting' status
                var instance = response.ReplicationInstances[0];
                var status = instance.ReplicationInstanceStatus.ToLowerInvariant();
                Console.WriteLine($"Replication instance {instanceIdentifier} deletion status: {instance.ReplicationInstanceStatus}");
                
                // If the instance failed to delete, we should stop waiting
                if (status == "failed" || status == "failed-delete")
                {
                    Console.WriteLine($"Warning: Replication instance {instanceIdentifier} deletion failed. Continuing with cleanup process.");
                    return;
                }

                await Task.Delay(_appSettings.Cleanup.PollingIntervalSeconds * 1000);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking replication instance deletion status: {ex.Message}");
                // If we get an error (like instance not found), it might mean it's been deleted
                // Continue with the cleanup process
                return;
            }
        }

        Console.WriteLine($"Warning: Timeout waiting for replication instance {instanceIdentifier} to be deleted. Continuing with cleanup process.");
    }

    static async Task ProcessOrphanedEndpointsAsync(AmazonDatabaseMigrationServiceClient dmsClient)
    {
        Console.WriteLine("Processing orphaned endpoints...");
        Console.WriteLine(new string('=', 80));

        try
        {
            // Get all endpoints in the region
            var allEndpoints = await GetAllEndpointsAsync(dmsClient);
            
            if (allEndpoints.Count == 0)
            {
                Console.WriteLine("No endpoints found in the region.");
                Console.WriteLine();
                return;
            }

            Console.WriteLine($"Found {allEndpoints.Count} total endpoints in the region.");
            Console.WriteLine();

            // Filter endpoints by prefixes
            var orphanedEndpoints = new List<Endpoint>();
            
            foreach (var prefix in _appSettings.Cleanup.OrphanedEndpointPrefixes)
            {
                var matchingEndpoints = allEndpoints.Where(e => e.EndpointIdentifier.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)).ToList();
                
                Console.WriteLine($"Found {matchingEndpoints.Count} endpoints with prefix '{prefix}':");
                foreach (var endpoint in matchingEndpoints)
                {
                    Console.WriteLine($"  - {endpoint.EndpointIdentifier} ({endpoint.EndpointType}) - Status: {endpoint.Status}");
                    if (!orphanedEndpoints.Any(e => e.EndpointArn == endpoint.EndpointArn))
                    {
                        orphanedEndpoints.Add(endpoint);
                    }
                }
                Console.WriteLine();
            }

            if (orphanedEndpoints.Count == 0)
            {
                Console.WriteLine("No orphaned endpoints found with the specified prefixes.");
                Console.WriteLine();
                return;
            }

            Console.WriteLine($"Total orphaned endpoints found: {orphanedEndpoints.Count}");
            Console.WriteLine();

            // Show user confirmation
            if (!_appSettings.Cleanup.DryRun)
            {
                Console.WriteLine("WARNING: The following endpoints will be PERMANENTLY DELETED!");
                foreach (var endpoint in orphanedEndpoints)
                {
                    Console.WriteLine($"  - {endpoint.EndpointIdentifier} (ARN: {endpoint.EndpointArn})");
                }
                Console.WriteLine();
                Console.WriteLine("Press 'Y' to proceed with deletion, or any other key to skip orphaned endpoint cleanup...");
                var key = Console.ReadKey();
                Console.WriteLine();
                
                if (key.Key != ConsoleKey.Y)
                {
                    Console.WriteLine("Orphaned endpoint cleanup cancelled by user.");
                    Console.WriteLine();
                    return;
                }
                Console.WriteLine();
            }

            // Delete orphaned endpoints
            Console.WriteLine("Deleting orphaned endpoints...");
            foreach (var endpoint in orphanedEndpoints)
            {
                await DeleteOrphanedEndpointAsync(dmsClient, endpoint);
            }
            
            Console.WriteLine("Orphaned endpoint cleanup completed!");
            Console.WriteLine();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error processing orphaned endpoints: {ex.Message}");
        }
    }

    static async Task<List<Endpoint>> GetAllEndpointsAsync(AmazonDatabaseMigrationServiceClient dmsClient)
    {
        try
        {
            var allEndpoints = new List<Endpoint>();
            string nextToken = null;

            do
            {
                var request = new DescribeEndpointsRequest
                {
                    MaxRecords = 100
                };
                
                if (!string.IsNullOrEmpty(nextToken))
                {
                    request.Marker = nextToken;
                }

                var response = await dmsClient.DescribeEndpointsAsync(request);
                allEndpoints.AddRange(response.Endpoints);
                nextToken = response.Marker;
            }
            while (!string.IsNullOrEmpty(nextToken));

            return allEndpoints;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error getting all endpoints: {ex.Message}");
            return new List<Endpoint>();
        }
    }

    static async Task DeleteOrphanedEndpointAsync(AmazonDatabaseMigrationServiceClient dmsClient, Endpoint endpoint)
    {
        try
        {
            if (_appSettings.Cleanup.DryRun)
            {
                Console.WriteLine($"[DRY RUN] Would delete orphaned endpoint: {endpoint.EndpointIdentifier} (ARN: {endpoint.EndpointArn})");
                return;
            }

            Console.WriteLine($"Deleting orphaned endpoint: {endpoint.EndpointIdentifier}");
            var deleteRequest = new DeleteEndpointRequest
            {
                EndpointArn = endpoint.EndpointArn
            };

            await dmsClient.DeleteEndpointAsync(deleteRequest);
            Console.WriteLine($"Successfully deleted orphaned endpoint: {endpoint.EndpointIdentifier}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error deleting orphaned endpoint {endpoint.EndpointIdentifier}: {ex.Message}");
        }
    }
}