using Cignium.Data.Extensions.LongRunning;
using Cignium.DatabaseShrinker;
using Cignium.WebJob.Models.Platform;
using Dapper;
using System.Data.SqlClient;

namespace Cignium.WebJob.Providers {
    public class DatabaseProvider {

        public DatabaseProvider() {
        }

        public Task<IReadOnlyList<IPlatformDatabase>> GetDatabasesAsync2()
        {
            var platformConnectionFactory = new PlatformConnectionDelegateFactory().Build();
            return GetDatabasesAsync(platformConnectionFactory);
        }

        public async Task<List<string>> GetDatabasesAsync()
        {
            var platformConnectionFactory = new PlatformConnectionDelegateFactory().Build();

            var databases = new List<string>();

            using (var connection = platformConnectionFactory())
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("SELECT name FROM sys.databases WHERE state = 0", connection))
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
        public async Task<IReadOnlyList<IPlatformDatabase>> GetDatabasesAsync(PlatformConnectionFactory platformConnectionFactory)
        {
            var serviceObjectives = await GetServiceObjectivesAsync(new MasterConnectionDelegateFactory(platformConnectionFactory).Build());
            var activeDatabases = await GetPlatformDatabasesAsync(platformConnectionFactory);

            return activeDatabases;
        }

        private string GetDatabasePoolName(IPlatformDatabase database, IEnumerable<ServiceObjectiveDto> enumerableServiceObjectives) {
            var serviceObjectives = enumerableServiceObjectives.ToList();

            var serviceObjective = serviceObjectives.SingleOrDefault(x => string.Equals(x.DatabaseName, database.DatabaseName, StringComparison.OrdinalIgnoreCase));
            var elasticPoolName = serviceObjective?.ElasticPoolName;
            if (elasticPoolName != null) {
                return elasticPoolName;
            }

            return GetDefaultElasticPoolName(serviceObjectives);
        }

        private async Task<IReadOnlyList<IPlatformDatabase>> GetPlatformDatabasesAsync(PlatformConnectionFactory platformConnectionFactory) {
            using (var connection = platformConnectionFactory()) {
                await connection.OpenAsync();
                var provisionedApplications = await connection.QueryAsync<Application>(@"
                                                            SELECT A.Id, A.Name, LOWER(REPLACE(A.Id,'-','')) DatabaseName, A.Priority, T.Name TenantName
                                                            FROM Application A
                                                                JOIN Tenant T
                                                                    ON (A.TenantId = T.Id)
                                                            WHERE [IsProvisioningCompleted] = 1");
                var provisionedChangesetDtos = await connection.QueryAsync<ChangesetDto>(@"
                                                            SELECT CH.ApplicationId, CH.Id, CH.Name, LOWER(REPLACE(CH.Id,'-',''))+'-changeset' DatabaseName
                                                            FROM Application A
                                                                JOIN Changeset CH
                                                                    ON (A.Id = CH.ApplicationId)
                                                            WHERE A.[IsProvisioningCompleted] = 1 AND CH.[IsProvisioned] = 1");
                var provisionedChangesets = provisionedChangesetDtos
                    .Select(x => {
                        var application = provisionedApplications.SingleOrDefault(a => a.Id == x.ApplicationId);
                        return new Changeset(x.Id, x.Name, x.DatabaseName, application);
                    })
                    .ToList();

                var activeDatabases = provisionedApplications.Cast<IPlatformDatabase>().Concat(provisionedChangesets).ToList();


                return activeDatabases.ToList();
            }
        }

        private async Task<IReadOnlyList<ServiceObjectiveDto>> GetServiceObjectivesAsync(MasterConnectionFactory masterConnectionFactory) {
            using (var connection = masterConnectionFactory()) {
                await connection.OpenAsync();

                var exists = connection.ExecuteScalar<int?>("SELECT OBJECT_ID('sys.database_service_objectives', 'V')");
                if (exists == null) {
                    return Enumerable.Empty<ServiceObjectiveDto>().ToList();
                }

                var serviceObjectives = await connection.QueryAsync<ServiceObjectiveDto>(@"
                    SELECT
	                    d.name DatabaseName,
	                    slo.database_id DatabaseId,
	                    slo.edition Edition,
	                    slo.service_objective ServiceObjective,
	                    slo.elastic_pool_name ElasticPoolName
                    FROM sys.databases d   
	                    JOIN sys.database_service_objectives slo    
		                    ON d.database_id = slo.database_id;");

                return serviceObjectives.ToList();
            }
        }

        private string GetDefaultElasticPoolName(IEnumerable<ServiceObjectiveDto> enumerableServiceObjectives) {
            var serviceObjectives = enumerableServiceObjectives.ToList();

            var sortedPools = serviceObjectives
                .Where(x => x.ElasticPoolName != null)
                .GroupBy(x => x.ElasticPoolName)
                .OrderByDescending(g => g.Count())
                .ThenBy(x => x.Key);

            return sortedPools.FirstOrDefault()?.Key;
        }
    }
}
