using System.Data.SqlClient;

namespace Cignium.WebJob {
    public delegate SqlConnection PlatformConnectionFactory();

    public class PlatformConnectionDelegateFactory {

        public PlatformConnectionDelegateFactory() {
        }

        public PlatformConnectionFactory Build() {
            return () => new SqlConnection("Data Source=tcp:lm-p-aze2-sql-001.database.windows.net,1433;Initial Catalog=master;User ID=cignium-lm@lm-p-aze2-sql-001;Password= 8Gyh30wg9m8b123wlFA2Y382d41QFu;MultipleActiveResultSets=true; Connection Timeout=30");
        }
    }

    public static class PlatformConnectionFactoryExtensions {
        private static string GetConnectionString(this PlatformConnectionFactory platformConnectionFactory) {
            using (var connection = platformConnectionFactory()) {
                return connection.ConnectionString;
            }
        }

        public static string GetServerName(this PlatformConnectionFactory platformConnectionFactory) {
            var builder = new SqlConnectionStringBuilder(platformConnectionFactory.GetConnectionString());

            var dataSource = builder.DataSource.Substring(builder.DataSource.IndexOf(':') + 1);

            var serverTokens = dataSource.Split('.');
            return serverTokens[0];
        }
    }
}