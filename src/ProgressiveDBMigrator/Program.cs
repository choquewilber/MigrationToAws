using System.Data.SqlClient;
using System.Text;
using Npgsql;

class Program
{
    static async Task Main()
    {
        var sqlConn = new SqlConnection("Data Source=tcp:lm-d-aze2-sql-001.database.windows.net,1433;Initial Catalog=14fdbfa9a03a49ed82ddbc271125e393-changeset;User ID=cignium-lm-dev@lm-d-aze2-sql-001;Password=KpuE4q22f53N00LMnv02Me46X99d6p;MultipleActiveResultSets=true");
        var pgConn = new NpgsqlConnection("Host=test-cdc-instance-1.c3dlgcnuafbx.us-east-2.rds.amazonaws.com;Database=14fdbfa9a03a49ed82ddbc271125e393-changeset;Username=postgres;Password=postgres;");

        // SQL Server to PostgreSQL Change Tracking Sync Tool
        // Supports multiple tables, dynamic columns, and sync_checkpoint tracking


        await sqlConn.OpenAsync();
        await pgConn.OpenAsync();

        await EnsureCheckpointTableExists(pgConn);
        await EnsureDatabaseChangeTrackingEnabled(sqlConn);

        // 👇 NEW: Ensure Change Tracking is enabled for all user tables
        var allTables = await GetAllUserTablesAsync(sqlConn);
        //foreach (var (schema, table) in allTables)
        //{
        //    await EnsureChangeTrackingEnabledAsync(sqlConn, schema, table);
        //}

        var tables = await GetChangeTrackingTablesAsync(sqlConn);

        foreach (var (schema, table) in tables)
        {
            string fullTableName = $"{schema}.{table}";

            long fromVersion = await GetLastSyncVersion(pgConn, fullTableName);

            long toVersion;
            using (var cmd = new SqlCommand("SELECT CHANGE_TRACKING_CURRENT_VERSION()", sqlConn))
                toVersion = (long)await cmd.ExecuteScalarAsync();

            //var columns = await GetTableColumnsAsync(sqlConn, schema, table);
            ////string columnList = string.Join(", ", columns.ConvertAll(c => $"D.{c}"));
            //string columnList = string.Join(", ", columns.ConvertAll(c => $"D.[{c}]"));

            //var query = $@"
            //    SELECT CT.Id, CT.SYS_CHANGE_OPERATION, {columnList}
            //    FROM CHANGETABLE(CHANGES {schema}.{table}, {fromVersion}) AS CT
            //    LEFT JOIN {schema}.{table} D ON D.Id = CT.Id";

            //using var cmdSql = new SqlCommand(query, sqlConn);
            //using var reader = await cmdSql.ExecuteReaderAsync();

            var columns = await GetTableColumnsAsync(sqlConn, schema, table);
            string columnList = string.Join(", ", columns.ConvertAll(c => $"D.[{c}]"));

            // Escape schema and table names
            string escapedSchema = $"[{schema}]";
            string escapedTable = $"[{table}]";

            var query = $@"
    SELECT CT.Id, CT.SYS_CHANGE_OPERATION, {columnList}
    FROM CHANGETABLE(CHANGES {escapedSchema}.{escapedTable}, {fromVersion}) AS CT
    LEFT JOIN {escapedSchema}.{escapedTable} D ON D.Id = CT.Id";

            using var cmdSql = new SqlCommand(query, sqlConn);
            using var reader = await cmdSql.ExecuteReaderAsync();


            //while (await reader.ReadAsync())
            //{
            //    int id = reader.GetInt32(0);
            //    string op = reader.GetString(1);

            //    if (op == "D")
            //    {
            //        var deleteCmd = new NpgsqlCommand($"DELETE FROM {table} WHERE id = @id", pgConn);
            //        deleteCmd.Parameters.AddWithValue("id", id);
            //        await deleteCmd.ExecuteNonQueryAsync();
            //        Console.WriteLine($"🗑️ DELETE {table} id={id}");
            //    }
            //    else
            //    {
            //        var upsert = new StringBuilder();
            //        upsert.Append($"INSERT INTO {table} (id, {string.Join(", ", columns)}) VALUES (@id");
            //        foreach (var col in columns)
            //            upsert.Append($", @{col}");
            //        upsert.Append(") ON CONFLICT (id) DO UPDATE SET ");
            //        upsert.Append(string.Join(", ", columns.ConvertAll(c => $"{c} = EXCLUDED.{c}")));

            //        var upsertCmd = new NpgsqlCommand(upsert.ToString(), pgConn);
            //        upsertCmd.Parameters.AddWithValue("id", id);

            //        for (int i = 0; i < columns.Count; i++)
            //        {
            //            var val = reader.IsDBNull(i + 2) ? DBNull.Value : reader.GetValue(i + 2);
            //            upsertCmd.Parameters.AddWithValue(columns[i], val);
            //        }

            //        await upsertCmd.ExecuteNonQueryAsync();
            //        Console.WriteLine($"📦 UPSERT {table} id={id}");
            //    }
            //}
            //while (await reader.ReadAsync())
            //{
            //    Guid id = reader.GetGuid(0); // ✅ Read Guid instead of int
            //    string op = reader.GetString(1);

            //    if (op == "D")
            //    {
            //        var deleteCmd = new NpgsqlCommand($"DELETE FROM {table} WHERE id = @id", pgConn);
            //        deleteCmd.Parameters.AddWithValue("id", id);
            //        await deleteCmd.ExecuteNonQueryAsync();
            //        Console.WriteLine($"🗑️ DELETE {table} id={id}");
            //    }
            //    else
            //    {
            //        var upsert = new StringBuilder();
            //        upsert.Append($"INSERT INTO {table} (id, {string.Join(", ", columns)}) VALUES (@id");
            //        foreach (var col in columns)
            //            upsert.Append($", @{col}");
            //        upsert.Append(") ON CONFLICT (id) DO UPDATE SET ");
            //        upsert.Append(string.Join(", ", columns.ConvertAll(c => $"{c} = EXCLUDED.{c}")));

            //        var upsertCmd = new NpgsqlCommand(upsert.ToString(), pgConn);
            //        upsertCmd.Parameters.AddWithValue("id", id); // ✅ Send Guid as-is to PostgreSQL (assumes UUID type)

            //        for (int i = 0; i < columns.Count; i++)
            //        {
            //            var val = reader.IsDBNull(i + 2) ? DBNull.Value : reader.GetValue(i + 2);
            //            upsertCmd.Parameters.AddWithValue(columns[i], val);
            //        }

            //        await upsertCmd.ExecuteNonQueryAsync();
            //        Console.WriteLine($"📦 UPSERT {table} id={id}");
            //    }
            //}

            while (await reader.ReadAsync())
            {
                Guid id = reader.GetGuid(0); // Read Id as Guid (UUID)
                string op = reader.GetString(1);

                // Properly quote schema and table for PostgreSQL
                string quotedTable = $"\"{schema}\".\"{table}\"";

                if (op == "D")
                {
                    var deleteCmd = new NpgsqlCommand($"DELETE FROM {quotedTable} WHERE \"Id\" = @id", pgConn);
                    deleteCmd.Parameters.AddWithValue("id", id);
                    await deleteCmd.ExecuteNonQueryAsync();
                    Console.WriteLine($"🗑️ DELETE {quotedTable} id={id}");
                }
                else
                {
                    // Quote each column to preserve PascalCase
                    var quotedColumns = columns.Select(c => $"\"{c}\"").ToList();

                    var upsert = new StringBuilder();
                    upsert.Append($"INSERT INTO {quotedTable} (\"Id\", {string.Join(", ", quotedColumns)}) VALUES (@id");
                    foreach (var col in columns)
                        upsert.Append($", @{col}");
                    upsert.Append(") ON CONFLICT (\"Id\") DO UPDATE SET ");
                    upsert.Append(string.Join(", ", columns.ConvertAll(c => $"\"{c}\" = EXCLUDED.\"{c}\"")));

                    var upsertCmd = new NpgsqlCommand(upsert.ToString(), pgConn);
                    upsertCmd.Parameters.AddWithValue("id", id);

                    for (int i = 0; i < columns.Count; i++)
                    {
                        var val = reader.IsDBNull(i + 2) ? DBNull.Value : reader.GetValue(i + 2);
                        upsertCmd.Parameters.AddWithValue(columns[i], val);
                    }

                    await upsertCmd.ExecuteNonQueryAsync();
                    Console.WriteLine($"📦 UPSERT {quotedTable} id={id}");
                }
            }



            await reader.CloseAsync();
            await SaveSyncVersion(pgConn, fullTableName, toVersion);
        }

        await sqlConn.CloseAsync();
        await pgConn.CloseAsync();
    }

    static async Task<List<(string schema, string table)>> GetAllUserTablesAsync(SqlConnection conn)
    {
        var result = new List<(string, string)>();
        var query = @"
            SELECT s.name AS schema_name, t.name AS table_name
            FROM sys.tables t
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE t.is_ms_shipped = 0";

        using var cmd = new SqlCommand(query, conn);
        using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
            result.Add((reader.GetString(0), reader.GetString(1)));
        return result;
    }

    static async Task<List<(string schema, string table)>> GetChangeTrackingTablesAsync(SqlConnection conn)
    {
        var result = new List<(string, string)>();
        var query = @"
            SELECT s.name AS schema_name, t.name AS table_name
            FROM sys.change_tracking_tables ct
            JOIN sys.tables t ON t.object_id = ct.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id";

        using var cmd = new SqlCommand(query, conn);
        using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
            result.Add((reader.GetString(0), reader.GetString(1)));
        return result;
    }

    static async Task<List<string>> GetTableColumnsAsync(SqlConnection conn, string schema, string table)
    {
        var result = new List<string>();
        var query = @"
            SELECT c.name
            FROM sys.columns c
            JOIN sys.tables t ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE t.name = @table AND s.name = @schema AND c.name <> 'Id'";

        using var cmd = new SqlCommand(query, conn);
        cmd.Parameters.AddWithValue("table", table);
        cmd.Parameters.AddWithValue("schema", schema);
        using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
            result.Add(reader.GetString(0));
        return result;
    }

    static async Task EnsureChangeTrackingEnabledAsync(SqlConnection conn, string schema, string table)
    {
        string checkQuery = @"
            SELECT COUNT(*)
            FROM sys.change_tracking_tables ct
            JOIN sys.tables t ON t.object_id = ct.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @schema AND t.name = @table";

        using var checkCmd = new SqlCommand(checkQuery, conn);
        checkCmd.Parameters.AddWithValue("schema", schema);
        checkCmd.Parameters.AddWithValue("table", table);

        var exists = (int)await checkCmd.ExecuteScalarAsync() > 0;

        if (!exists)
        {
            string enableQuery = $"ALTER TABLE [{schema}].[{table}] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);";
            using var enableCmd = new SqlCommand(enableQuery, conn);
            await enableCmd.ExecuteNonQueryAsync();
            Console.WriteLine($"✅ Change Tracking ENABLED on {schema}.{table}");
        }
        else
        {
            Console.WriteLine($"✔️ Change Tracking already enabled on {schema}.{table}");
        }
    }

    static async Task EnsureCheckpointTableExists(NpgsqlConnection pgConn)
    {
        var createTableSql = @"
            CREATE TABLE IF NOT EXISTS sync_checkpoint (
                table_name TEXT PRIMARY KEY,
                last_sync_version BIGINT NOT NULL
            );";

        using var cmd = new NpgsqlCommand(createTableSql, pgConn);
        await cmd.ExecuteNonQueryAsync();
        Console.WriteLine("📌 Checked/created sync_checkpoint table.");
    }

    static async Task EnsureDatabaseChangeTrackingEnabled(SqlConnection conn)
    {
        var checkQuery = "SELECT 1 FROM sys.change_tracking_databases WHERE database_id = DB_ID()";
        using var checkCmd = new SqlCommand(checkQuery, conn);
        var result = await checkCmd.ExecuteScalarAsync();

        if (result == null)
        {
            var enableCmd = new SqlCommand("ALTER DATABASE CURRENT SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);", conn);
            await enableCmd.ExecuteNonQueryAsync();
            Console.WriteLine("✅ Change Tracking enabled at database level.");
        }
        else
        {
            Console.WriteLine("✔️ Change Tracking already enabled at database level.");
        }
    }

    static async Task<long> GetLastSyncVersion(NpgsqlConnection pgConn, string tableName)
    {
        var cmd = new NpgsqlCommand("SELECT last_sync_version FROM sync_checkpoint WHERE table_name = @t", pgConn);
        cmd.Parameters.AddWithValue("t", tableName);
        var result = await cmd.ExecuteScalarAsync();
        return result == null ? 0 : (long)result;
    }

    static async Task SaveSyncVersion(NpgsqlConnection pgConn, string tableName, long version)
    {
        var cmd = new NpgsqlCommand(@"
            INSERT INTO sync_checkpoint (table_name, last_sync_version)
            VALUES (@t, @v)
            ON CONFLICT (table_name) DO UPDATE
            SET last_sync_version = EXCLUDED.last_sync_version;", pgConn);

        cmd.Parameters.AddWithValue("t", tableName);
        cmd.Parameters.AddWithValue("v", version);
        await cmd.ExecuteNonQueryAsync();
    }
}
