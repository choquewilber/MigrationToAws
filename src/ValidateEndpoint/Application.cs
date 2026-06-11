namespace Cignium.WebJob.Models.Platform {
    public class Application : IPlatformDatabase {
        private readonly List<Changeset> _changesets;

        public Guid Id { get; }
        public string Name { get; }
        public IReadOnlyList<Changeset> Changesets => _changesets;

        public string DatabaseName { get; }
        public string Description => Name;
        public DatabasePriority Priority { get; }
        public DatabaseType DatabaseType => DatabaseType.Runtime;

        //public string DatabasePoolName {
        //    get => DatabasePool?.Name;
        //    set => DatabasePool = new DatabasePool { Name = value };
        //}
        //public DatabasePool DatabasePool { get; set; }

        public string TenantName { get; }

        public Application(Guid id, string name, string databaseName, DatabasePriority priority, string tenantName) {
            Id = id;
            Name = name;
            DatabaseName = databaseName;
            Priority = priority;
            TenantName = tenantName;
            _changesets = new List<Changeset>();
        }

        public void Add(Changeset changeset) {
            _changesets.Add(changeset);
        }

        public override bool Equals(object value) {
            var other = value as Application;
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