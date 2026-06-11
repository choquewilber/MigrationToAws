# CreateInstances Tool

This tool supports both creating new AWS DMS replication instances and scaling existing ones.

## Configuration

Configure the operation in `appsettings.json`:

### Creating New Instances
Set `Operation.Mode` to `"Create"`:
{
  "Operation": {
    "Mode": "Create"
  },
  "Aws": {
    "ReplicationInstance": {
      "InstanceClass": "dms.r5.16xlarge",
      "InstanceCount": 9,
      "InstanceIdentifierPrefix": "pr-multi-db-replication-instance",
      "StartingIndex": 1,
      "BatchSize": 2
    }
  }
}
### Scaling Existing Instances

Set `Operation.Mode` to `"Scale"` or `"ScaleDown"`:
{
  "Operation": {
    "Mode": "ScaleDown",
    "InstanceIdentifiers": [
      "pr-multi-db-replication-instance-1",
      "pr-multi-db-replication-instance-2"
    ],
    "ApplyImmediately": false
  },
  "Aws": {
    "ReplicationInstance": {
      "TargetInstanceClass": "dms.r5.large",
      "TargetAllocatedStorage": 0
    }
  }
}
## Configuration Options

### Operation Settings
- **Mode**: `"Create"`, `"Scale"`, or `"ScaleDown"`
- **InstanceIdentifiers**: List of specific instance identifiers to scale (**Note: Use identifiers, not ARNs**)
- **ApplyImmediately**: `true` to apply changes immediately, `false` to apply during maintenance window

### Replication Instance Settings
- **TargetInstanceClass**: Target instance class for scaling operations (e.g., `"dms.r5.large"`)
- **TargetAllocatedStorage**: Target storage in GB (set to 0 for no storage change)

## Important Notes

### Instance Identifiers vs ARNs
**Always use instance identifiers, not ARNs** in the `InstanceIdentifiers` array:

? **Correct:**"InstanceIdentifiers": [
  "pr-multi-db-replication-instance-1",
  "pr-multi-db-replication-instance-2"
]
? **Incorrect:**"InstanceIdentifiers": [
  "arn:aws:dms:us-east-2:123456789012:rep:ABCDEFGHIJK"
]
### Storage Limitations
- Storage can only be **increased**, not decreased
- AWS DMS does not support reducing allocated storage
- If you specify a target storage smaller than current, the storage change will be skipped

### Instance State Requirements
- Instances must be in `available` state to be modified
- The tool will skip instances that are not in the correct state

## Examples

### Scale Down from 16xlarge to large{
  "Operation": {
    "Mode": "ScaleDown",
    "ApplyImmediately": false
  },
  "Aws": {
    "ReplicationInstance": {
      "TargetInstanceClass": "dms.r5.large",
      "InstanceIdentifierPrefix": "pr-multi-db-replication-instance",
      "StartingIndex": 1,
      "InstanceCount": 9
    }
  }
}
### Scale Specific Instances{
  "Operation": {
    "Mode": "Scale",
    "InstanceIdentifiers": [
      "my-replication-instance-1",
      "my-replication-instance-2"
    ],
    "ApplyImmediately": true
  },
  "Aws": {
    "ReplicationInstance": {
      "TargetInstanceClass": "dms.r5.xlarge"
    }
  }
}
## Error Handling

The tool includes comprehensive error handling:

- **Invalid identifiers**: Detects and warns about ARNs used instead of identifiers
- **Missing instances**: Gracefully handles instances that don't exist
- **Invalid states**: Skips instances not in `available` state
- **Storage validation**: Prevents attempts to reduce storage
- **AWS API errors**: Provides meaningful error messages for common issues

## Troubleshooting

### "replicationInstanceArn must not be null" Error
This error was fixed by ensuring the tool uses the correct ARN internally while accepting instance identifiers in configuration.

### Instance Not Found
- Verify the instance identifier is correct
- Ensure the instance exists in the specified AWS region
- Check that your AWS credentials have permissions to access DMS

### Instance Class Not Supported
- Verify the target instance class is supported in your region
- Check AWS DMS documentation for available instance classes