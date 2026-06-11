using System.Data;

namespace Cignium.Data.Extensions.LongRunning {
    public static class DbConnectionExtensions {
        public static void ExecuteNonQuery(this IDbConnection connection, string commandText, int commandTimeout = 600) {
            using (var command = connection.CreateCommand()) {
                command.CommandText = commandText;
                command.CommandTimeout = commandTimeout;
                command.ExecuteNonQuery();
            }
        }

        public static T ExecuteScalar<T>(this IDbConnection connection, string commandText) {
            using (var command = connection.CreateCommand()) {
                command.CommandTimeout = 600;
                command.CommandText = commandText;
                return (T)command.ExecuteScalar();
            }
        }
    }
}