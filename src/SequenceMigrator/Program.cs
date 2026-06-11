using System.Data.SqlClient;
using Dapper;
using Npgsql;

class SequenceSync
{
    static void Main(string[] args)
    {
        const string sqlServerConnTemplate = "Data Source=tcp:lm-d-aze2-sql-001.database.windows.net,1433;Initial Catalog={0};User ID=cignium-lm-dev;Password=KpuE4q22f53N00LMnv02Me46X99d6p;MultipleActiveResultSets=true";
        const string postgresConnTemplate = "Host=lm-aurora-cluster-dev.cluster-c3dlgcnuafbx.us-east-2.rds.amazonaws.com;Port=5432;Database={0};Username=lm-app;Password=squnfrte5GUtUshQRaBc4q3fVMMnWD";

        var databases = new List<string>
        {
            //"34202668340f436a8de8c96930ca4163",
            //"5037fbfab80545b2a27ff098f710104c",
            //"f3c03a726dfb4654aa5e28c2a275a130",
            //"0d5455114c94439e8738903ff427c887",
            //"81d83a7290654f8ca30c3c3d2afd3cea",
            //"c37c087cf5a34163ae954a7017c18939",
            //"07469def1f304aeea45d4a8cdcdf46d7",
            //"4e64c9ca67ea40ec8475fbf1d9eb4abc",
            //"9e359145fa1e49f8b07203e80569a361",
            //"c7a55e8b2cfb4c7d9908c21502dea041",
            //"b93c6dedbe344bc2b04bdfd7dbdfa4a7",
            //"6900e658e4cf4b77ba8feb958b91cbb9",
            //"e7c7dc86f31b4b6e9aa5c045414adcc0",
            "071c1b028a144d6b8eef49c2741666f2",
            "0a59fc32763e4bc0bdd7dd42dffdd938"
        };
        var failedDatabases = new List<(string Db, string Error)>();

        var sequences = new List<(string SqlSeq, string PgSeq)>
        {
            ("Platform_ApplicationVersion_Sequence", "\"Platform_ApplicationVersion_Sequence\""),
            ("Platform_ApplicationVersion_VersionMajor", "\"Platform_ApplicationVersion_VersionMajor\""),
            ("ValueSet_ValueSetReferenceId_Sequence", "\"Platform\".\"ValueSet_ValueSetReferenceId_Sequence\"")
        };


        foreach (var db in databases)
        {
            try
            {
                // 1. Conexión a SQL Server (origen)
                var sqlServerConn = string.Format(sqlServerConnTemplate, db);
                var seqValues = new Dictionary<string, long>();

                using (var sql = new SqlConnection(sqlServerConn))
                {
                    sql.Open();

                    foreach (var (sqlSeq, _) in sequences)
                    {
                        var currentVal = sql.ExecuteScalar<long>(
                            "SELECT current_value FROM sys.sequences WHERE name = @name",
                            new { name = sqlSeq }
                        );
                        seqValues[sqlSeq] = currentVal + 1;
                    }
                }

                // 2. Conexión a Postgres (destino)
                var pgConnStr = string.Format(postgresConnTemplate, db);
                using (var pg = new NpgsqlConnection(pgConnStr))
                {
                    pg.Open();

                    foreach (var (sqlSeq, pgSeq) in sequences)
                    {
                        var nextVal = seqValues[sqlSeq];
                        var alterSql = $"ALTER SEQUENCE {pgSeq} RESTART WITH {nextVal};";
                        pg.Execute(alterSql);

                        Console.WriteLine($"✅ {db}: {pgSeq} seteado a {nextVal}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error en DB {db}: {ex.Message}");
                failedDatabases.Add((db, ex.Message));
            }
        }

        Console.WriteLine("\n--- RESUMEN ---");
        if (failedDatabases.Count > 0)
        {
            Console.WriteLine("Bases con error:");
            foreach (var (db, err) in failedDatabases)
                Console.WriteLine($" - {db}: {err}");
        }
        else
        {
            Console.WriteLine("Todas las bases fueron actualizadas correctamente ✅");
        }
    }
}