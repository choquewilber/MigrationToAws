using System.Data.SqlClient;

namespace Cignium.WebJob {
    public delegate SqlConnection MasterConnectionFactory();

    public class MasterConnectionDelegateFactory {
        private readonly string _masterConnectionString;

        public MasterConnectionDelegateFactory(PlatformConnectionFactory platformConnectionFactory) {
            using (var connection = platformConnectionFactory()) {
                var builder = new SqlConnectionStringBuilder(connection.ConnectionString) {
                    InitialCatalog = "master"
                };
                _masterConnectionString = builder.ConnectionString;
            }
        }

        public MasterConnectionFactory Build() {
            return () => new SqlConnection(_masterConnectionString);
        }
    }
}