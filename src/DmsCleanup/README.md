# AWS DMS Cleanup Tool

This console application helps you clean up AWS Database Migration Service (DMS) resources by deleting completed replication tasks, their associated endpoints, and optionally the replication instances themselves. It also supports cleaning up orphaned endpoints that are no longer associated with any replication tasks.

## Features

- Delete replication tasks based on their status (stopped, failed, completed)
- Cancel running tasks before deletion (configurable)
- Delete associated source and target endpoints
- Delete replication instances after all tasks and endpoints have been cleaned up
- **Clean up orphaned endpoints by prefix** (useful when tasks/instances are already deleted)
- Support for multiple replication instances
- Dry run mode to preview what would be deleted
- Interactive confirmation for orphaned endpoint deletion
- Configurable authentication methods (Access Key, Shared Credentials File, IAM Role)

## Configuration

Edit the `appsettings.json` file to configure the application:

### AWS Settings
{
  "Aws": {
    "AuthenticationMethod": "AccessKey", // "AccessKey", "SharedCredentialsFile", or "IAMRole"
    "AccessKey": "YOUR_ACCESS_KEY_HERE", // Required for AccessKey authentication
    "SecretKey": "YOUR_SECRET_KEY_HERE", // Required for AccessKey authentication
    "ProfileName": "", // Required for SharedCredentialsFile authentication
    "Region": "us-east-2" // AWS region where your DMS resources are located
  }
}
### Cleanup Settings
{
  "Cleanup": {
    "ReplicationInstanceArns": [
      "arn:aws:dms:us-east-2:123456789012:rep:your-instance-1",
      "arn:aws:dms:us-east-2:123456789012:rep:your-instance-2"
    ],
    "DryRun": true, // Set to false to actually delete resources
    "TaskStatusesToDelete": [ "stopped", "failed", "completed" ],
    "PollingIntervalSeconds": 5, // Polling interval when waiting for task status changes
    "DeleteEndpoints": true, // Whether to delete endpoints after deleting tasks
    "DeleteTasks": true, // Whether to delete replication tasks
    "DeleteReplicationInstance": false, // Whether to delete the replication instance after cleaning up tasks and endpoints
    "CancelRunningTasks": false, // Whether to cancel running tasks before deletion
    "CleanupOrphanedEndpoints": true, // Whether to search for and clean up orphaned endpoints
    "OrphanedEndpointPrefixes": [ "source-endpoint1", "targetfinal11" ] // Prefixes to search for orphaned endpoints
  }
}
## Usage

1. **Configure your settings**: Edit `appsettings.json` with your AWS credentials and replication instance ARNs.

2. **Test with dry run**: First run with `"DryRun": true` to see what would be deleted:dotnet run
3. **Actual cleanup**: Change `"DryRun": false` and run again to actually delete resources:dotnet run
## Safety Features

- **Dry Run Mode**: By default, the application runs in dry run mode and only shows what would be deleted
- **User Confirmation**: When dry run is disabled, the application asks for confirmation before proceeding
- **Interactive Orphaned Endpoint Deletion**: Additional confirmation prompt specifically for orphaned endpoints
- **Status Filtering**: Only deletes tasks with specified statuses (configurable)
- **Running Task Protection**: By default, running tasks are protected from deletion unless `CancelRunningTasks` is enabled
- **Error Handling**: Continues processing other resources even if some operations fail
- **Validation**: Verifies that all tasks are deleted before attempting to delete the replication instance

## Task Processing Flow

1. **Discovery**: Find all replication tasks associated with each replication instance
2. **Running Task Detection**: Identify any running tasks and handle them based on `CancelRunningTasks` setting
3. **Filtering**: Filter tasks by their status (only delete stopped/failed/completed tasks, plus running tasks if configured)
4. **Task Cancellation**: If `CancelRunningTasks` is enabled, stop running tasks first
5. **Endpoint Collection**: Collect all source and target endpoints from tasks to be deleted
6. **Task Deletion**: Delete replication tasks (waits for cancellation to complete, then waits for deletion to complete)
7. **Endpoint Deletion**: Delete collected endpoints (only after all tasks are fully deleted)
8. **Instance Deletion**: Delete replication instance (only if configured and all tasks have been removed)
9. **Orphaned Endpoint Cleanup**: Search for and delete endpoints matching specified prefixes (if configured)

## Orphaned Endpoint Cleanup

When replication tasks and instances have already been deleted but endpoints remain, you can use the orphaned endpoint cleanup feature:

### Configuration
- Set `"CleanupOrphanedEndpoints": true`
- Add endpoint prefixes to `"OrphanedEndpointPrefixes"` array
- Example: `["source-endpoint1", "targetfinal11"]`

### Process
1. The tool searches all endpoints in the region
2. Filters endpoints that start with the specified prefixes
3. Displays found endpoints with their details
4. Prompts for user confirmation before deletion
5. Deletes confirmed endpoints

### Example Output for Orphaned EndpointsProcessing orphaned endpoints...
================================================================================
Found 25 total endpoints in the region.

Found 3 endpoints with prefix 'source-endpoint1':
  - source-endpoint1-db1 (source) - Status: available
  - source-endpoint1-db2 (source) - Status: available
  - source-endpoint1-test (source) - Status: available

Found 2 endpoints with prefix 'targetfinal11':
  - targetfinal11-prod (target) - Status: available
  - targetfinal11-staging (target) - Status: available

Total orphaned endpoints found: 5

WARNING: The following endpoints will be PERMANENTLY DELETED!
  - source-endpoint1-db1 (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:source-endpoint1-db1)
  - source-endpoint1-db2 (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:source-endpoint1-db2)
  - source-endpoint1-test (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:source-endpoint1-test)
  - targetfinal11-prod (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:targetfinal11-prod)
  - targetfinal11-staging (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:targetfinal11-staging)

Press 'Y' to proceed with deletion, or any other key to skip orphaned endpoint cleanup...
## Running Task Handling

The application provides configurable handling for running replication tasks:

- **Default Behavior** (`CancelRunningTasks: false`): Running tasks are skipped and protected from deletion
- **Cancel and Delete** (`CancelRunningTasks: true`): Running tasks are cancelled first, then deleted

When `CancelRunningTasks` is enabled:
1. Running tasks are identified and cancelled
2. The application waits for cancellation to complete (up to 5 minutes)
3. Once cancelled, tasks are deleted following the normal deletion process

## Authentication Methods

### Access Key (Recommended for development){
  "AuthenticationMethod": "AccessKey",
  "AccessKey": "AKIAIOSFODNN7EXAMPLE",
  "SecretKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
### Shared Credentials File{
  "AuthenticationMethod": "SharedCredentialsFile",
  "ProfileName": "your-profile-name"
}
### IAM Role (For EC2 instances){
  "AuthenticationMethod": "IAMRole"
}
## Required AWS Permissions

The AWS credentials used must have the following permissions:
- `dms:DescribeReplicationTasks`
- `dms:DeleteReplicationTask`
- `dms:StopReplicationTask`
- `dms:DescribeEndpoints`
- `dms:DeleteEndpoint`
- `dms:DescribeReplicationInstances`
- `dms:DeleteReplicationInstance`

## Example Output
AWS DMS Cleanup Tool
===================

Using AWS authentication method: AccessKey
Successfully created credentials using Access Key and Secret Key
Connected to AWS DMS in region: us-east-2
Dry Run Mode: ENABLED
Cancel Running Tasks: ENABLED
Cleanup Orphaned Endpoints: ENABLED

WARNING: This is a DRY RUN. No resources will be deleted.
Set 'Cleanup.DryRun' to false in appsettings.json to actually delete resources.

Processing replication instance: arn:aws:dms:us-east-2:123456789012:rep:my-instance
--------------------------------------------------------------------------------
Found 3 replication tasks for this instance:
  - migration-task-db1 (Status: completed)
  - migration-task-db2 (Status: running)
  - migration-task-db3 (Status: stopped)

Found 1 running tasks:
  - migration-task-db2 (Status: running)

CancelRunningTasks is enabled. Running tasks will be cancelled and added to deletion list.

Found 3 tasks to delete:
  - migration-task-db1 (Status: completed)
  - migration-task-db3 (Status: stopped)
  - migration-task-db2 (Status: running)

Found 6 unique endpoints to delete:
  - arn:aws:dms:us-east-2:123456789012:endpoint:source-db1
  - arn:aws:dms:us-east-2:123456789012:endpoint:target-db1
  - arn:aws:dms:us-east-2:123456789012:endpoint:source-db2
  - arn:aws:dms:us-east-2:123456789012:endpoint:target-db2
  - arn:aws:dms:us-east-2:123456789012:endpoint:source-db3
  - arn:aws:dms:us-east-2:123456789012:endpoint:target-db3

Deleting replication tasks...
[DRY RUN] Would delete replication task: migration-task-db1
[DRY RUN] Would delete replication task: migration-task-db3
[DRY RUN] Would cancel and delete running replication task: migration-task-db2

Deleting endpoints...
[DRY RUN] Would delete endpoint: arn:aws:dms:us-east-2:123456789012:endpoint:source-db1
[DRY RUN] Would delete endpoint: arn:aws:dms:us-east-2:123456789012:endpoint:target-db1
[DRY RUN] Would delete endpoint: arn:aws:dms:us-east-2:123456789012:endpoint:source-db2
[DRY RUN] Would delete endpoint: arn:aws:dms:us-east-2:123456789012:endpoint:target-db2
[DRY RUN] Would delete endpoint: arn:aws:dms:us-east-2:123456789012:endpoint:source-db3
[DRY RUN] Would delete endpoint: arn:aws:dms:us-east-2:123456789012:endpoint:target-db3

[DRY RUN] Would delete replication instance: arn:aws:dms:us-east-2:123456789012:rep:my-instance

Processing orphaned endpoints...
================================================================================
Found 5 total endpoints in the region.

Found 2 endpoints with prefix 'source-endpoint1':
  - source-endpoint1-legacy (source) - Status: available
  - source-endpoint1-backup (source) - Status: available

Found 1 endpoints with prefix 'targetfinal11':
  - targetfinal11-main (target) - Status: available

Total orphaned endpoints found: 3

[DRY RUN] Would delete orphaned endpoint: source-endpoint1-legacy (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:source-endpoint1-legacy)
[DRY RUN] Would delete orphaned endpoint: source-endpoint1-backup (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:source-endpoint1-backup)
[DRY RUN] Would delete orphaned endpoint: targetfinal11-main (ARN: arn:aws:dms:us-east-2:123456789012:endpoint:targetfinal11-main)

Orphaned endpoint cleanup completed!

DMS cleanup completed!
## Notes

- The application automatically stops running tasks before deleting them when `CancelRunningTasks` is enabled
- Tasks are fully deleted and verified before proceeding with endpoint deletion
- Endpoints are only deleted if they're not used by other replication tasks
- Replication instances are only deleted if all associated tasks have been removed
- The application processes each replication instance sequentially
- Failed operations are logged but don't stop the overall cleanup process
- Task deletion verification has a 10-minute timeout to prevent indefinite waiting
- Replication instance deletion verification has a 15-minute timeout
- If `DeleteReplicationInstance` is set to `true`, the instance will only be deleted after all tasks and endpoints have been successfully removed
- Running tasks are protected by default - enable `CancelRunningTasks` to include them in cleanup operations
- **Orphaned endpoint cleanup runs after all replication instance processing is complete**
- **Orphaned endpoints require separate user confirmation even when dry run is disabled**