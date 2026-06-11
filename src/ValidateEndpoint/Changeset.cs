
namespace Cignium.WebJob.Models.Platform {
    public class Changeset : IPlatformDatabase {
        public Guid Id { get; }
        public string Name { get; }

        public Application Application { get; }

        public DateTimeOffset? LastModificationDate { get; set; }

        public string DatabaseName { get; }
        public string Description => $"{Application.Name} - {Name}";
        public DatabasePriority Priority => Application.Priority;
        public DatabaseType DatabaseType => DatabaseType.Designer;

        //public string DatabasePoolName {
        //    get => DatabasePool?.Name;
        //    set => DatabasePool = new DatabasePool { Name = value };
        //}
        //public DatabasePool DatabasePool { get; set; }

        public string TenantName => Application.TenantName;

        public Changeset(Guid id, string name, string databaseName, Application application) {
            Id = id;
            Name = name;
            DatabaseName = databaseName;
            Application = application;
            Application?.Add(this);
        }

        public override bool Equals(object value) {
            var other = value as Changeset;
            if (other == null) {
                return false;
            }

            return EqualityComparer<Guid>.Default.Equals(Id, other.Id);
        }

        public override int GetHashCode() {
            return EqualityComparer<Guid>.Default.GetHashCode(Id);
        }
    }
}