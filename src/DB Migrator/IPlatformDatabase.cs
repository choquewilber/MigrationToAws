namespace DBMigrator.Models;

public interface IPlatformDatabase {
    string DatabaseName { get; }
    string Description { get; }
    DatabasePriority Priority { get; }
    DatabaseType DatabaseType { get; }
    string TenantName { get; }
}