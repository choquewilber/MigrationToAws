using System;
using System.Collections.Generic;

namespace DBFixerMigration.Models;

public class FailedTaskReport
{
    public string DatabaseName { get; set; } = string.Empty;
    public string SchemaName { get; set; } = string.Empty;
    public string TableName { get; set; } = string.Empty;
    public string ErrorDescription { get; set; } = string.Empty;
    public long RowsMigrated { get; set; }
    public long TotalRows { get; set; }
    public string TaskArn { get; set; } = string.Empty;
    public string ReplicationInstanceArn { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime LastUpdated { get; set; }
}

public class ReplicationInstanceTaskInfo
{
    public string ReplicationInstanceArn { get; set; } = string.Empty;
    public string InstanceIdentifier { get; set; } = string.Empty;
    public List<TaskInfo> Tasks { get; set; } = new();
    public int CurrentTaskCount => Tasks.Count;
    public int CurrentEndpointCount => Tasks.Count * 2; // Source + Target
    public bool CanAcceptMoreTasks => CurrentTaskCount < 50 && CurrentEndpointCount < 100;
    public int AvailableTaskSlots => Math.Max(0, 50 - CurrentTaskCount);
    public int AvailableEndpointSlots => Math.Max(0, 100 - CurrentEndpointCount);
}

public class TaskInfo
{
    public string TaskArn { get; set; } = string.Empty;
    public string TaskIdentifier { get; set; } = string.Empty;
    public string DatabaseName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public bool HasErrors { get; set; }
    public bool IsCompleted => Status.ToLowerInvariant() is "stopped" or "completed";
    public bool IsFailed => Status.ToLowerInvariant() is "failed";
    public List<FailedTaskReport> FailedTables { get; set; } = new();
    public DateTime? StartTime { get; set; }
    public DateTime? StopTime { get; set; }
    public long? FullLoadProgressPercent { get; set; }
    public string? LastFailureMessage { get; set; }
}