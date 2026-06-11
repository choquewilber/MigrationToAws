using System;

namespace DBFixerMigration.Models;

public class DatabaseMigration
{
    public string DatabaseName { get; set; }
    public string Schema { get; set; } = string.Empty;

    // SQL Server (Source) properties
    public string SourceServerName { get; set; }
    public int SourcePort { get; set; } = 1433;
    public string SourceUsername { get; set; }
    public string SourcePassword { get; set; }

    // PostgreSQL (Target) properties
    public string TargetServerName { get; set; }
    public int TargetPort { get; set; } = 5432;
    public string TargetUsername { get; set; }
    public string TargetPassword { get; set; }

    // Optional migration settings
    public bool IncludeSchema { get; set; } = true;
    public bool IncludeData { get; set; } = true;
    public bool DropAndCreateTables { get; set; } = false;

    public DatabaseMigration(string databaseName, string sourceServerName, string targetServerName, string sourceUsername, string sourcePassword, string targetUsername, string targetPassword)
    {
        DatabaseName = databaseName;
        SourceServerName = sourceServerName;
        TargetServerName = targetServerName;
        SourceUsername = sourceUsername;
        SourcePassword = sourcePassword;
        TargetUsername = targetUsername;
        TargetPassword = targetPassword;
        IncludeSchema = true;
        IncludeData = true;
        DropAndCreateTables = true;
    }

    public override string ToString()
    {
        return $"Database: {DatabaseName}, Source: {SourceServerName}:{SourcePort}, Target: {TargetServerName}:{TargetPort}";
    }
}