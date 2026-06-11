using System.ComponentModel;
using System.Text;
using Amazon;
using Amazon.DatabaseMigrationService;
using Amazon.DatabaseMigrationService.Model;
using Amazon.Runtime.CredentialManagement;
using DBMigrator;
using DatabaseProvider = Cignium.WebJob.Providers.DatabaseProvider;

class Program
{
    private static readonly SemaphoreSlim fileLock = new SemaphoreSlim(1, 1); // Control de acceso al archivo

    static async Task Main(string[] args)
    {
        var profileName = "tzdev";
        var sharedFile = new SharedCredentialsFile();
        sharedFile.TryGetProfile(profileName, out var profile);
        AWSCredentialsFactory.TryGetAWSCredentials(profile, sharedFile, out var credentials);
        var dmsClient = new AmazonDatabaseMigrationServiceClient(credentials, RegionEndpoint.USEast2);

        var timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        var resultFilePath = $@"C:\Users\wilber.choque\source\repos\ValidateEndpoint\ValidateEndpoint_{timestamp}.csv";

        var _databases = await new DatabaseProvider().GetDatabasesAsync();
        _databases = _databases.Where(x => x.Contains("changeset")).ToList();

        var errors = new List<string>(){
"97e84384091f465ba9116a16d73e307d-changeset",
"ac6f6a8b7b174547a5f5fffc0e40a5b3-changeset",
"9896ecfacc4d46709b365f1b50cc5cb5-changeset",
"db2a8588a11b46cfa98f715d0acd21a6-changeset",
"9cbff27ab8ce4926932958891469dc23-changeset",
"ca0e29e1dfae4ce395569a4f715b988b-changeset",
"e82621b3c34e4d0b84aac3f92ee9d964-changeset",
"fbfa0b7ff6014399af14cfff6f968bb2-changeset",
"23900195ae7d4da5a2b22ac9bebefe63-changeset",
"00d96dca7b384cef8842b82fdd680c53-changeset",
"862c298b18c9422f8443e9e5c8d23dc5-changeset",
"1a09ed8e653941968f097ab2330f0baf-changeset",
"1282f2e6055b4a9b91673ea35b12dd2a-changeset",
"f48cb44329bc402fb78d0eda3f4b54a6-changeset",
"b5e5b519d13b41888910736fd6481f6d-changeset",
"ab977e2434644fcda60c26be43830829-changeset",
"ef9995c2d2ab4166bb865d919f091167-changeset",
"cbe3416ca9d84683956c78c6a23b0d7b-changeset",
"4f0d44526f6346518c1b340fb6772d81-changeset",
"ac048692a07d45b1a81a13c5b3eedfd2-changeset",
"157c980a581d4b36a0af0249cbdd7450-changeset",
"ddfeb7ae8826447ca6538594f3f0e9fe-changeset",
"6a441c77627c498daef6730d8c68529d-changeset",
"89d52c3629c046c0ad3212907c87be51-changeset",
"fe523fb60d734214b55df1d59df417f5-changeset",
"5b5fec01117849e5a290fbf86c2b19c7-changeset",
"103a2e28ee604f52b7ca39cffb9bf93b-changeset",
"9e1d080895df4a438114018cd350e97a-changeset",
"04881a90bd234e3ba8c90c80e67a741f-changeset",
"f3bc66587633490e94f9356e0b71c43f-changeset",
"b35687661ca7463abb6ea6464297376c-changeset",
"fd7a3637a02541879933f8c18f65dac1-changeset",
"cd7c226946d24a88a3656b3eb7c3ee20-changeset",
"917cd0eeb6fb4f90ab542ef7dcd7ee23-changeset",
"b532efcadaf74e7397d618715c9ea74e-changeset",
"d3117059db9e48d38d9ea38d5ad48522-changeset",
"c5f68be66a8b4ec1b74e103d12fa4a0a-changeset",
"4e7c2460f6bb4c99a9466e6df94379fc-changeset",
"fd113d2fc6b84d0381130eb420cbbf88-changeset",
"826be973a0084feb838328b1e0eed419-changeset",
"55db70d7a4dd4aea837d1321d8774149-changeset",
"ec34a5eef4784cc5a09247b5ac8e338c-changeset",
"6ef1917a22c7460ea29a27a12aa8ee82-changeset",
"94d17aa78b3d4622ab46603fd8d5a960-changeset",
"1c5071b4b1824ec0bdf5f0e7db908f30-changeset",
"5ee08bce903c4add8a63aceb3c8cafe3-changeset",
"36fe6899bc254de2a493932605685cb3-changeset",
"37709123c0d14a8f84c95ea39bb168af-changeset",
"85499c1577c24d3ebdc4a915ff33b82d-changeset",
"858c5b9d9dbf485c91da474fd790f159-changeset",
"37bca017ad0b4f1bae2b453c915890d3-changeset",
"5d67dd04fdd14946aaa41cdfc95a9fa8-changeset",
"477c77130c2d481e9049b756344d0f21-changeset",
"1d33e07bd76c4ff9b02e72e26eaf9f28-changeset",
"ad9b7ca3ab20412fa08bac109ee2618a-changeset",
"07f026803bdb43e9a1aeb496ac90d0f6-changeset",
"d101fa9a25d64681b53397aaf05e0545-changeset"


        };

        _databases = _databases.Where(x => errors.Contains(x)).ToList();

        //var databasesToMigrate = _databases.Select(x =>
        //    new DatabaseMigration(x, "YOUR_SERVER", "target-platform-instance-1.c3dlgcnuafbx.us-east-2.rds.amazonaws.com")
        //    {
        //        SourceUsername = "cignium-lm-dev@lm-d-aze2-sql-001",
        //        SourcePassword = "YOUR_PASSWORD",
        //        TargetUsername = "postgres",
        //        TargetPassword = "postgres",
        //        IncludeSchema = true,
        //        IncludeData = true,
        //        DropAndCreateTables = true
        //    }).ToList();

        var databasesToMigrate = _databases.Select(x =>
            new DatabaseMigration(x, "lm-p-aze2-sql-001.database.windows.net", "database-1lm-instance-1.c3dlgcnuafbx.us-east-2.rds.amazonaws.com",string.Empty, String.Empty, String.Empty, string.Empty)
            {
                SourceUsername = "cignium-lm@lm-p-aze2-sql-001",
                SourcePassword = "8Gyh30wg9m8b123wlFA2Y382d41QFu",
                TargetUsername = "postgres",
                TargetPassword = "postgres",
                IncludeSchema = true,
                IncludeData = true,
                DropAndCreateTables = true
            }).ToList();

        var replicationInstanceArns = new[]
        {
            "arn:aws:dms:us-east-2:025381531841:rep:QVOO4IMB2NCLTEMMQUMTB6NWQI",
            "arn:aws:dms:us-east-2:025381531841:rep:6XRXBFSUFVE63F6Q2UI2BK7GUA"
        };

        int batchSize = 20;
        for (int i = 0; i < databasesToMigrate.Count; i += batchSize)
        {
            var batch = databasesToMigrate.Skip(i).Take(batchSize).ToList();
            string replicationInstanceArn = replicationInstanceArns[(i / batchSize) % replicationInstanceArns.Length];

            Console.WriteLine($"Processing batch {i / batchSize + 1}: Databases {i + 1} to {i + batch.Count} using instance {replicationInstanceArn}");

            var tasks = batch.Select(db => TestConnectionForDatabaseAsync(replicationInstanceArn, db, resultFilePath, dmsClient));
            await Task.WhenAll(tasks);
        }
    }

    public static async Task TestConnectionForDatabaseAsync(string replicationInstanceArn,
        DatabaseMigration db, string resultFilePath, AmazonDatabaseMigrationServiceClient dmsClient)
    {
        try
        {
            Console.WriteLine($"Testing connection for database: {db.DatabaseName}");
            var endpointArn = await CreateOrUpdateSourceEndpointAsync(db, dmsClient);

            bool isConnected = await TestEndpointConnectionAsync(endpointArn, replicationInstanceArn, dmsClient);

            string status = isConnected ? "Success" : "Failure";
            string message = isConnected ? "Connected successfully" : "Connection failed";

            await WriteResultToFileAsync(resultFilePath, db.DatabaseName, status, message);

            await dmsClient.DeleteEndpointAsync(new DeleteEndpointRequest { EndpointArn = endpointArn });
        }
        catch (Exception ex)
        {
            await WriteResultToFileAsync(resultFilePath, db.DatabaseName, "Error", ex.Message);
        }
    }

    private static async Task WriteResultToFileAsync(string filePath, string databaseName, string status, string message)
    {
        await fileLock.WaitAsync();
        try
        {
            using (var writer = new StreamWriter(filePath, true, Encoding.UTF8))
            {
                await writer.WriteLineAsync($"{databaseName},{status},{message}");
            }
        }
        finally
        {
            fileLock.Release();
        }
    }

    private static async Task<string> CreateOrUpdateSourceEndpointAsync(DatabaseMigration db, AmazonDatabaseMigrationServiceClient dmsClient)
    {
        var request = new CreateEndpointRequest
        {
            EndpointIdentifier = $"source-endpoint-new-prodv4-{db.DatabaseName}",
            EndpointType = ReplicationEndpointTypeValue.Source,
            EngineName = "sqlserver",
            ServerName = db.SourceServerName,
            Port = db.SourcePort,
            DatabaseName = db.DatabaseName,
            Username = db.SourceUsername,
            Password = db.SourcePassword
        };

        var response = await dmsClient.CreateEndpointAsync(request);
        return response.Endpoint.EndpointArn;
    }

    public static async Task<bool> TestEndpointConnectionAsync(string endpointArn, string replicationInstanceArn, AmazonDatabaseMigrationServiceClient dmsClient)
    {
        var request = new TestConnectionRequest
        {
            EndpointArn = endpointArn,
            ReplicationInstanceArn = replicationInstanceArn
        };

        var response = await dmsClient.TestConnectionAsync(request);
        Console.WriteLine($"Testing connection for endpoint ARN: {endpointArn}, Status: {response.Connection.Status}");

        var connection = response.Connection;
        while (connection.Status == "testing")
        {
            Console.WriteLine("Connection is still testing... waiting for completion.");
            await Task.Delay(5000);

            var describeRequest = new DescribeConnectionsRequest
            {
                Filters = new List<Filter>
                {
                    new Filter
                    {
                        Name = "endpoint-arn",
                        Values = new List<string> { endpointArn }
                    }
                }
            };

            var describeResponse = await dmsClient.DescribeConnectionsAsync(describeRequest);
            connection = describeResponse.Connections.FirstOrDefault();

            if (connection == null)
            {
                Console.WriteLine("No connection information found.");
                return false;
            }

            Console.WriteLine($"Current connection status: {connection.Status}");
        }

        return connection.Status == "successful";
    }
}
