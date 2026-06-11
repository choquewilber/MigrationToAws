using Amazon;
using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using Amazon.Runtime;
using Amazon.Runtime.CredentialManagement;
using Microsoft.Extensions.Configuration;
using DmsMigrationAutomation.Models;

namespace DmsMigrationAutomation
{
    class Program
    {
        private static AppSettings _appSettings = null!;
        private static IConfiguration _configuration = null!;

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

            // Create AWS credentials based on the authentication method
            var credentials = await CreateAwsCredentialsAsync(_appSettings.Aws);
            
            var region = RegionEndpoint.GetBySystemName(_appSettings.Aws.Region);
            var dmsClient = new AmazonDatabaseMigrationServiceClient(credentials, region);

            // Determine operation mode
            var operationMode = _appSettings.Operation.Mode.ToLowerInvariant();
            Console.WriteLine($"Operation Mode: {operationMode}");

            switch (operationMode)
            {
                case "create":
                    await CreateReplicationInstances(dmsClient);
                    break;
                case "scale":
                case "scaledown":
                    await ScaleReplicationInstances(dmsClient);
                    break;
                default:
                    throw new ArgumentException($"Unsupported operation mode: {_appSettings.Operation.Mode}. Supported modes are: Create, Scale, ScaleDown");
            }
        }

        static async Task CreateReplicationInstances(AmazonDatabaseMigrationServiceClient dmsClient)
        {
            var tasks = new List<Task>();
            var batchSize = _appSettings.Aws.ReplicationInstance.BatchSize;
            var startingIndex = _appSettings.Aws.ReplicationInstance.StartingIndex;
            var instanceCount = _appSettings.Aws.ReplicationInstance.InstanceCount;

            Console.WriteLine($"Creating {instanceCount} replication instances starting from index {startingIndex} in batches of {batchSize}");
            Console.WriteLine($"Instance range: {startingIndex} to {startingIndex + instanceCount - 1}");

            for (int i = 0; i < instanceCount; i++)
            {
                int instanceNumber = startingIndex + i;
                string instanceIdentifier = $"{_appSettings.Aws.ReplicationInstance.InstanceIdentifierPrefix}-{instanceNumber}";
                tasks.Add(CreateReplicationInstance(dmsClient, _appSettings.Aws.SubnetGroupIdentifier, _appSettings.Aws.SecurityGroupIds, instanceIdentifier));
            }

            await Task.WhenAll(tasks);
            Console.WriteLine($"All {instanceCount} replication instances have been created successfully.");
            Console.WriteLine($"Next batch should start with StartingIndex: {startingIndex + instanceCount}");
        }

        static async Task ScaleReplicationInstances(AmazonDatabaseMigrationServiceClient dmsClient)
        {
            var targetInstanceClass = _appSettings.Aws.ReplicationInstance.TargetInstanceClass;
            var targetStorage = _appSettings.Aws.ReplicationInstance.TargetAllocatedStorage;
            
            if (string.IsNullOrEmpty(targetInstanceClass) && targetStorage == 0)
            {
                throw new ArgumentException("Either TargetInstanceClass or TargetAllocatedStorage must be specified for scaling operations.");
            }

            var instanceIdentifiers = _appSettings.Operation.InstanceIdentifiers;
            
            // If no specific instances are provided, generate them based on prefix and range
            if (instanceIdentifiers.Count == 0)
            {
                var startingIndex = _appSettings.Aws.ReplicationInstance.StartingIndex;
                var instanceCount = _appSettings.Aws.ReplicationInstance.InstanceCount;
                var prefix = _appSettings.Aws.ReplicationInstance.InstanceIdentifierPrefix;
                
                for (int i = 0; i < instanceCount; i++)
                {
                    int instanceNumber = startingIndex + i;
                    instanceIdentifiers.Add($"{prefix}-{instanceNumber}");
                }
            }

            // Validate that we have instance identifiers, not ARNs
            var invalidIdentifiers = instanceIdentifiers.Where(id => id.StartsWith("arn:")).ToList();
            if (invalidIdentifiers.Any())
            {
                Console.WriteLine("Warning: The following entries appear to be ARNs instead of instance identifiers:");
                foreach (var invalid in invalidIdentifiers)
                {
                    Console.WriteLine($"  - {invalid}");
                }
                Console.WriteLine("Please use instance identifiers (e.g., 'my-replication-instance-1') instead of ARNs.");
                Console.WriteLine("Operation will continue but these entries will likely fail.");
                Console.WriteLine();
            }

            Console.WriteLine($"Scaling {instanceIdentifiers.Count} replication instances:");
            foreach (var identifier in instanceIdentifiers)
            {
                Console.WriteLine($"  - {identifier}");
            }
            Console.WriteLine();
            
            if (!string.IsNullOrEmpty(targetInstanceClass))
            {
                Console.WriteLine($"Target Instance Class: {targetInstanceClass}");
            }
            if (targetStorage > 0)
            {
                Console.WriteLine($"Target Allocated Storage: {targetStorage} GB");
            }
            Console.WriteLine($"Apply Immediately: {_appSettings.Operation.ApplyImmediately}");
            Console.WriteLine();

            var tasks = new List<Task>();
            foreach (var instanceIdentifier in instanceIdentifiers)
            {
                tasks.Add(ModifyReplicationInstance(dmsClient, instanceIdentifier, targetInstanceClass, targetStorage));
            }

            await Task.WhenAll(tasks);
            Console.WriteLine($"All {instanceIdentifiers.Count} replication instances have been processed.");
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

        static async Task CreateReplicationInstance(AmazonDatabaseMigrationServiceClient dmsClient,
            string subnetGroupIdentifier, List<string> securityGroupIds, string instanceIdentifier)
        {
            var request = new CreateReplicationInstanceRequest
            {
                ReplicationInstanceIdentifier = instanceIdentifier,
                ReplicationInstanceClass = _appSettings.Aws.ReplicationInstance.InstanceClass,
                AllocatedStorage = _appSettings.Aws.ReplicationInstance.AllocatedStorage,
                EngineVersion = _appSettings.Aws.ReplicationInstance.EngineVersion,
                PubliclyAccessible = _appSettings.Aws.ReplicationInstance.PubliclyAccessible,
                VpcSecurityGroupIds = securityGroupIds,
                ReplicationSubnetGroupIdentifier = subnetGroupIdentifier,
                MultiAZ = _appSettings.Aws.ReplicationInstance.MultiAZ
            };

            var response = await dmsClient.CreateReplicationInstanceAsync(request);
            string replicationInstanceArn = response.ReplicationInstance.ReplicationInstanceArn;
            Console.WriteLine(
                $"Replication instance created with ARN: {replicationInstanceArn}. Waiting for it to become active...");

            await WaitForInstanceToBeAvailable(dmsClient, replicationInstanceArn, instanceIdentifier);
        }

        static async Task ModifyReplicationInstance(AmazonDatabaseMigrationServiceClient dmsClient,
            string instanceIdentifier, string targetInstanceClass, int targetStorage)
        {
            try
            {
                // Validate input - check if it's an ARN instead of identifier
                if (instanceIdentifier.StartsWith("arn:"))
                {
                    Console.WriteLine($"Error: '{instanceIdentifier}' appears to be an ARN. Please use the instance identifier instead.");
                    Console.WriteLine("You can find the instance identifier in the AWS DMS console or by using the describe-replication-instances AWS CLI command.");
                    return;
                }

                Console.WriteLine($"Processing replication instance: {instanceIdentifier}");
                
                // First, get the current instance details
                var describeRequest = new DescribeReplicationInstancesRequest
                {
                    Filters = new List<Filter>
                    {
                        new Filter
                        {
                            Name = "replication-instance-id", 
                            Values = new List<string> { instanceIdentifier }
                        }
                    }
                };

                var describeResponse = await dmsClient.DescribeReplicationInstancesAsync(describeRequest);
                
                if (describeResponse.ReplicationInstances.Count == 0)
                {
                    Console.WriteLine($"Warning: Replication instance '{instanceIdentifier}' not found. Skipping...");
                    Console.WriteLine("Please verify the instance identifier is correct and the instance exists in the specified region.");
                    return;
                }

                var currentInstance = describeResponse.ReplicationInstances[0];
                var currentInstanceClass = currentInstance.ReplicationInstanceClass;
                var currentStorage = currentInstance.AllocatedStorage;
                var replicationInstanceArn = currentInstance.ReplicationInstanceArn;

                Console.WriteLine($"Found instance '{instanceIdentifier}': Class={currentInstanceClass}, Storage={currentStorage}GB, Status={currentInstance.ReplicationInstanceStatus}");

                // Check if instance is in a modifiable state
                if (currentInstance.ReplicationInstanceStatus != "available")
                {
                    Console.WriteLine($"Warning: Instance '{instanceIdentifier}' is in '{currentInstance.ReplicationInstanceStatus}' state. Modifications can only be made when the instance is 'available'. Skipping...");
                    return;
                }

                // Build the modify request using ARN
                var modifyRequest = new ModifyReplicationInstanceRequest
                {
                    ReplicationInstanceArn = replicationInstanceArn,
                    ApplyImmediately = _appSettings.Operation.ApplyImmediately
                };

                bool hasChanges = false;

                // Set target instance class if specified and different from current
                if (!string.IsNullOrEmpty(targetInstanceClass) && targetInstanceClass != currentInstanceClass)
                {
                    modifyRequest.ReplicationInstanceClass = targetInstanceClass;
                    hasChanges = true;
                    Console.WriteLine($"Will change instance class from {currentInstanceClass} to {targetInstanceClass}");
                }

                // Set target storage if specified and different from current
                if (targetStorage > 0 && targetStorage != currentStorage)
                {
                    if (targetStorage < currentStorage)
                    {
                        Console.WriteLine($"Warning: Cannot reduce storage from {currentStorage}GB to {targetStorage}GB. AWS DMS does not support reducing allocated storage. Skipping storage change.");
                    }
                    else
                    {
                        modifyRequest.AllocatedStorage = targetStorage;
                        hasChanges = true;
                        Console.WriteLine($"Will change allocated storage from {currentStorage}GB to {targetStorage}GB");
                    }
                }

                if (!hasChanges)
                {
                    Console.WriteLine($"No changes needed for instance '{instanceIdentifier}'. Current configuration matches target.");
                    return;
                }

                // Apply the modifications
                Console.WriteLine($"Modifying replication instance '{instanceIdentifier}'...");
                var modifyResponse = await dmsClient.ModifyReplicationInstanceAsync(modifyRequest);
                
                string modifiedInstanceArn = modifyResponse.ReplicationInstance.ReplicationInstanceArn;
                Console.WriteLine($"Modification request submitted successfully. Waiting for completion...");

                await WaitForInstanceToBeAvailable(dmsClient, modifiedInstanceArn, instanceIdentifier);
            }
            catch (AmazonDatabaseMigrationServiceException ex)
            {
                Console.WriteLine($"Error modifying replication instance '{instanceIdentifier}': {ex.Message}");
                if (ex.ErrorCode == "InvalidParameterValueException")
                {
                    Console.WriteLine("This might be due to an invalid instance class or other parameter. Please check the AWS DMS documentation for supported instance classes.");
                }
                // Don't re-throw, continue with other instances
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Unexpected error modifying replication instance '{instanceIdentifier}': {ex.Message}");
                // Don't re-throw, continue with other instances
            }
        }

        static async Task WaitForInstanceToBeAvailable(AmazonDatabaseMigrationServiceClient dmsClient, 
            string replicationInstanceArn, string instanceIdentifier)
        {
            while (true)
            {
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
                var instance = describeResponse.ReplicationInstances[0];

                if (instance.ReplicationInstanceStatus == "available")
                {
                    Console.WriteLine($"Replication instance {instanceIdentifier} is now active and available.");
                    Console.WriteLine($"Current configuration: Class={instance.ReplicationInstanceClass}, Storage={instance.AllocatedStorage}GB");
                    break;
                }

                Console.WriteLine($"Current status for {instanceIdentifier}: {instance.ReplicationInstanceStatus}. Waiting...");
                await Task.Delay(_appSettings.Migration.PollingIntervalSeconds * 1000);
            }
        }
    }
}
