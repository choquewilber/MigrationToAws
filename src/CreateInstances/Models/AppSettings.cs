namespace DmsMigrationAutomation.Models
{
    public class AppSettings
    {
        public AwsSettings Aws { get; set; } = new();
        public MigrationSettings Migration { get; set; } = new();
        public OperationSettings Operation { get; set; } = new();
    }

    public class AwsSettings
    {
        public string AuthenticationMethod { get; set; } = "SharedCredentialsFile"; // Options: "SharedCredentialsFile", "AccessKey", "IAMRole"
        public string ProfileName { get; set; } = string.Empty; // For SharedCredentialsFile
        public string AccessKey { get; set; } = string.Empty; // For AccessKey authentication
        public string SecretKey { get; set; } = string.Empty; // For AccessKey authentication
        public string RoleArn { get; set; } = string.Empty; // For IAMRole authentication
        public string Region { get; set; } = string.Empty;
        public List<string> SecurityGroupIds { get; set; } = new();
        public string SubnetGroupIdentifier { get; set; } = string.Empty;
        public ReplicationInstanceSettings ReplicationInstance { get; set; } = new();
    }

    public class ReplicationInstanceSettings
    {
        public string InstanceClass { get; set; } = string.Empty;
        public int AllocatedStorage { get; set; } = 50;
        public string EngineVersion { get; set; } = string.Empty;
        public bool PubliclyAccessible { get; set; } = true;
        public bool MultiAZ { get; set; } = false;
        public int InstanceCount { get; set; } = 1;
        public string InstanceIdentifierPrefix { get; set; } = string.Empty;
        public int StartingIndex { get; set; } = 1; // Starting index for instance numbering
        public int BatchSize { get; set; } = 2; // Number of instances to create in each batch
        
        // Settings for scaling operations
        public string TargetInstanceClass { get; set; } = string.Empty; // Target instance class for scaling down
        public int TargetAllocatedStorage { get; set; } = 0; // Target storage for scaling (0 means no change)
    }

    public class OperationSettings
    {
        public string Mode { get; set; } = "Create"; // Options: "Create", "Scale", "ScaleDown"
        public List<string> InstanceIdentifiers { get; set; } = new(); // Specific instance identifiers for scaling operations
        public bool ApplyImmediately { get; set; } = false; // Whether to apply changes immediately or during maintenance window
    }

    public class MigrationSettings
    {
        public int PollingIntervalSeconds { get; set; } = 10;
    }
}