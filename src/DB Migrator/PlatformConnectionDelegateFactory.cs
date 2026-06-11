using System.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace DBMigrator;

public delegate SqlConnection PlatformConnectionFactory();

public class PlatformConnectionDelegateFactory {
    private readonly IConfiguration _configuration;

    public PlatformConnectionDelegateFactory() {
        var builder = new ConfigurationBuilder()
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .AddJsonFile("appsettings.Development.json", optional: true, reloadOnChange: true);
        
        _configuration = builder.Build();
    }

    public PlatformConnectionFactory Build() {
        var connectionString = _configuration.GetConnectionString("SourceServer");
        
        if (string.IsNullOrEmpty(connectionString))
        {
            throw new InvalidOperationException("SourceServer connection string not found in configuration.");
        }
        
        return () => new SqlConnection(connectionString);
    }
}