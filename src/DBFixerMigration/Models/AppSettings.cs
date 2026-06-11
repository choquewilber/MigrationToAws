using System;
using System.Collections.Generic;

namespace DBFixerMigration.Models;

public class AppSettings
{
    public DatabaseSettings Database { get; set; } = new();
    public AwsSettings Aws { get; set; } = new();
    public SqlScriptSettings SqlScripts { get; set; } = new();
    public LoggingSettings LoggingFile { get; set; } = new();
    public FixerSettings Fixer { get; set; } = new();
    public RetryFixerSettings RetryFixer { get; set; } = new();
}

public class DatabaseSettings
{
    public string SourceServerName { get; set; } = string.Empty;
    public string TargetServerName { get; set; } = string.Empty;
    public string SourceUsername { get; set; } = string.Empty;
    public string SourcePassword { get; set; } = string.Empty;
    public string TargetUsername { get; set; } = string.Empty;
    public string TargetPassword { get; set; } = string.Empty;
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
    public List<string> ReplicationInstanceArns { get; set; } = new();
}

public class SqlScriptSettings
{
    public string ChangesetConstraintScript { get; set; } = string.Empty;
    public string PlatformConstraintsScript { get; set; } = string.Empty;
    public string RuntimeConstraintsScript { get; set; } = string.Empty;
}

public class LoggingSettings
{
    public string MigrationLogFilePath { get; set; } = string.Empty;
    public string LogFileFormat { get; set; } = "csv";
    public bool EnableMigrationLogging { get; set; } = true;
}

public class FixerSettings
{
    public string FailedTasksCsvPath { get; set; } = "failed_tasks_report.csv";
    public bool AutoExecutePostScripts { get; set; } = true;
    public int MaxTasksPerInstance { get; set; } = 50;
    public int MaxEndpointsPerInstance { get; set; } = 100;
    public int PollingIntervalSeconds { get; set; } = 15;
    public bool InteractiveMode { get; set; } = true;
}

public class RetryFixerSettings
{
    public bool EnableInteractiveRetry { get; set; } = true;
    public int MaxRetryAttempts { get; set; } = 3;
    public int RetryDelayMinutes { get; set; } = 5;
    public string RetryTaskPrefix { get; set; } = "fixer-retry";
    public RetryTaskSettings RetryTaskConfiguration { get; set; } = new();
    public List<TableRetryRule> TableWhitelist { get; set; } = new();
}

public class TableRetryRule
{
    public string SchemaPattern { get; set; } = string.Empty;
    public string TablePattern { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}

public class RetryTaskSettings
{
    public int CommitRateDuringFullLoad { get; set; } = 100;
    public int LobChunkSizeKb { get; set; } = 96;
    public int InlineLobMaxSizeKb { get; set; } = 64;
    public int MaxLobSizeKb { get; set; } = 32768; // 32MB default
    public bool UseFullLobMode { get; set; } = true;
    public string TargetTablePrepMode { get; set; } = "TRUNCATE_BEFORE_LOAD";
}