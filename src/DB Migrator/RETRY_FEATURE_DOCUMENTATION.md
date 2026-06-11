# Failed Table Retry Feature - Implementation Summary

## Overview
This implementation adds automatic retry functionality for specific tables that fail during DMS migration, with specialized LOB settings for handling large objects like SerializedTableRule.

## Key Components Added

### 1. Configuration Settings (`AppSettings.cs`)
- `RetrySettings` class with configurable retry parameters
- `TableRetryRule` class for whitelist pattern matching
- `RetryTaskSettings` class for specialized LOB configurations

### 2. Table Retry Manager (`TableRetryManager.cs`)
- Detects failed tables using DMS table statistics
- Matches failed tables against configured whitelist patterns
- Creates retry tasks with optimized LOB settings
- Handles multiple retry attempts with configurable delays

### 3. Enhanced Migration Manager (`DatabaseMigrationManager.cs`)
- Integrates retry logic into the main migration flow
- Calls retry functionality after main migration completes
- Handles both successful and failed migrations gracefully

## Configuration Example (appsettings.json)

```json
"Retry": {
  "EnableRetryOnFailedTables": true,
  "MaxRetryAttempts": 3,
  "RetryDelayMinutes": 5,
  "TableWhitelist": [
    {
      "SchemaPattern": "TableRuleRuntime",
      "TablePattern": "SerializedTableRule",
      "Description": "Runtime table rule serialization data with LOB content"
    },
    {
      "SchemaPattern": "dbo",
      "TablePattern": "TableRuleRuntime", 
      "Description": "Main runtime table rules"
    }
  ],
  "RetryTaskConfiguration": {
    "CommitRateDuringFullLoad": 100,
    "LobChunkSizeKb": 96,
    "InlineLobMaxSizeKb": 64,
    "MaxLobSizeKb": 32768,
    "UseFullLobMode": true
  }
}
```

## How It Works

1. **Main Migration**: Normal DMS migration runs as before
2. **Failure Detection**: After completion, system checks table statistics for failures
3. **Pattern Matching**: Failed tables are matched against whitelist patterns using wildcards
4. **Retry Logic**: Creates new DMS task with optimized LOB settings for failed tables only
5. **Multiple Attempts**: Supports configurable retry attempts with delays

## LOB Optimization Settings

The retry tasks use specific settings optimized for LOB handling:
- **Commit Rate**: 100 (integer range from 1 to 1000000000)
- **LOB Chunk Size**: 96 KB (for Full LOB Mode piecewise migration)
- **Inline LOB Max Size**: 64 KB (LOBs smaller than this are transferred inline)
- **Full LOB Mode**: Enabled for large LOB handling

## Pattern Matching

Supports wildcard patterns:
- `*` matches any sequence of characters
- `?` matches any single character
- Case-insensitive matching

## Error Handling

- Retry failures don't stop the overall migration process
- Detailed logging for retry attempts
- Automatic cleanup of retry endpoints
- Graceful handling of DMS API errors

## Benefits

- Automatic recovery for specific problematic tables
- Optimized settings for LOB-heavy tables like SerializedTableRule
- Configurable and maintainable whitelist approach
- Non-blocking retry process that doesn't affect main migration flow