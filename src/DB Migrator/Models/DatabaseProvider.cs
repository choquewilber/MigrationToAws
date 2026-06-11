using System.Data.SqlClient;

namespace DBMigrator.Models;

public class DatabaseProvider
{

    public DatabaseProvider()
    {
    }

    public async Task<List<string>> GetDatabasesAsync()
    {
        var platformConnectionFactory = new PlatformConnectionDelegateFactory().Build();

        var databases = new List<string>();

        using (var connection = platformConnectionFactory())
        {
            await connection.OpenAsync();

            using (var command = new SqlCommand("select * from sys.databases where state = 0 and (name not like '%-changeset%' and name not like '%platform%' and name not like '%test001%' and name not like '%master%')", connection))
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    databases.Add(reader.GetString(0));
                }
            }
        }

        return databases;
    }
}