namespace DBMigrator.Models;

public class ChangesetDto {
    public Guid ApplicationId { get; }
    public Guid Id { get; }
    public string Name { get; }
    public string DatabaseName { get; }

    public ChangesetDto(Guid applicationId, Guid id, string name, string databaseName) {
        ApplicationId = applicationId;
        Id = id;
        Name = name;
        DatabaseName = databaseName;
    }
}