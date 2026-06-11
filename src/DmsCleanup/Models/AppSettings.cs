namespace DmsCleanup.Models
{
    public class AppSettings
    {
        public AwsSettings Aws { get; set; } = new();
        public CleanupSettings Cleanup { get; set; } = new();
    }

    public class AwsSettings
    {
        public string AuthenticationMethod { get; set; } = "AccessKey"; // Options: "SharedCredentialsFile", "AccessKey", "IAMRole"
        public string ProfileName { get; set; } = string.Empty; // For SharedCredentialsFile
        public string AccessKey { get; set; } = string.Empty; // For AccessKey authentication
        public string SecretKey { get; set; } = string.Empty; // For AccessKey authentication
        public string RoleArn { get; set; } = string.Empty; // For IAMRole authentication
        public string Region { get; set; } = string.Empty;
    }

    public class CleanupSettings
    {
        public List<string> ReplicationInstanceArns { get; set; } = new();
        public bool DryRun { get; set; } = false; // Set to false to actually delete resources
        public List<string> TaskStatusesToDelete { get; set; } = new() { "stopped", "failed", "completed" };
        public int PollingIntervalSeconds { get; set; } = 5;
        public bool DeleteEndpoints { get; set; } = true;
        public bool DeleteTasks { get; set; } = true;
        public bool DeleteReplicationInstance { get; set; } = false; // Whether to delete the replication instance after cleaning up tasks and endpoints
        public bool CancelRunningTasks { get; set; } = false; // Whether to cancel running tasks before deletion
        public bool CleanupOrphanedEndpoints { get; set; } = false; // Whether to search for and clean up orphaned endpoints
        public List<string> OrphanedEndpointPrefixes { get; set; } = new(); // Prefixes to search for orphaned endpoints
    }
}