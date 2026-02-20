using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace BuildingBlocks.Persistence;

public static class PlatformPersistenceExtensions
{
    public static IServiceCollection AddPlatformPersistence(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.Configure<PersistenceOptions>(configuration.GetSection(PersistenceOptions.SectionName));
        services.AddDbContextFactory<PlatformDbContext>((provider, options) =>
        {
            var persistenceOptions = provider.GetRequiredService<IOptions<PersistenceOptions>>().Value;

            if (!persistenceOptions.Provider.Equals("postgres", StringComparison.OrdinalIgnoreCase))
            {
                throw new NotSupportedException(
                    $"Unsupported persistence provider '{persistenceOptions.Provider}'. Supported: postgres.");
            }

            options.UseNpgsql(
                persistenceOptions.ConnectionString,
                npgsqlOptions => npgsqlOptions.EnableRetryOnFailure(3));
        });

        services.AddHealthChecks()
            .AddCheck<PersistenceHealthCheck>("persistence");

        return services;
    }
}

public sealed class PersistenceOptions
{
    public const string SectionName = "Persistence";
    public string ConnectionString { get; init; } = string.Empty;
    public string Provider { get; init; } = "postgres";
}

internal sealed class PersistenceHealthCheck : IHealthCheck
{
    private readonly IOptions<PersistenceOptions> _options;
    private readonly IDbContextFactory<PlatformDbContext> _dbContextFactory;

    public PersistenceHealthCheck(
        IOptions<PersistenceOptions> options,
        IDbContextFactory<PlatformDbContext> dbContextFactory)
    {
        _options = options;
        _dbContextFactory = dbContextFactory;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var configured = !string.IsNullOrWhiteSpace(_options.Value.ConnectionString);
        if (!configured)
        {
            return HealthCheckResult.Unhealthy("Persistence:ConnectionString is missing.");
        }

        try
        {
            await using var dbContext = await _dbContextFactory.CreateDbContextAsync(cancellationToken);
            var canConnect = await dbContext.Database.CanConnectAsync(cancellationToken);
            return canConnect
                ? HealthCheckResult.Healthy("Persistence is reachable.")
                : HealthCheckResult.Unhealthy("Persistence is configured but not reachable.");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Persistence connectivity check failed.", ex);
        }
    }
}

public sealed class PlatformDbContext : DbContext
{
    public PlatformDbContext(DbContextOptions<PlatformDbContext> options)
        : base(options)
    {
    }
}
