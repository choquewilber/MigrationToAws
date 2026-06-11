namespace Cignium.WebJob.Models.Platform {
    public interface IPlatformDatabase {
        string DatabaseName { get; }
        string Description { get; }
        DatabasePriority Priority { get; }
        DatabaseType DatabaseType { get; }

        //string DatabasePoolName { get; set; }
        //DatabasePool DatabasePool { get; set; }

        string TenantName { get; }
    }
}