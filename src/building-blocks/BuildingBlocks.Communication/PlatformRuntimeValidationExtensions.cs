using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BuildingBlocks.Communication;

public static class PlatformRuntimeValidationExtensions
{
    public static IServiceCollection ValidatePlatformConfiguration(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var errors = new List<string>();

        ValidateRequired(configuration, "Authentication:Audience", errors);
        ValidateRequired(configuration, "Authorization:RequiredScope", errors);
        ValidateRequired(configuration, "Authorization:TenantClaim", errors);
        ValidateRequired(configuration, "Persistence:ConnectionString", errors);
        ValidateRequired(configuration, "Encryption:ApplicationName", errors);

        var platformTarget = configuration["Runtime:PlatformTarget"];
        if (string.IsNullOrWhiteSpace(platformTarget) ||
            (platformTarget is not "dev" and not "gcp" and not "onprem"))
        {
            errors.Add("Runtime:PlatformTarget must be 'dev', 'gcp', or 'onprem'.");
        }

        var authority = configuration["Authentication:Authority"];
        var issuer = configuration["Authentication:Issuer"];
        var signingKey = configuration["Authentication:SigningKey"];
        if (string.IsNullOrWhiteSpace(authority) &&
            (string.IsNullOrWhiteSpace(issuer) || string.IsNullOrWhiteSpace(signingKey)))
        {
            errors.Add(
                "Authentication configuration invalid: set 'Authentication:Authority', or set both " +
                "'Authentication:Issuer' and 'Authentication:SigningKey'.");
        }

        var broker = configuration["Messaging:Broker"];
        if (string.Equals(broker, "rabbitmq", StringComparison.OrdinalIgnoreCase))
        {
            ValidateRequired(configuration, "Messaging:Host", errors);
            ValidateRequired(configuration, "Messaging:Username", errors);
            ValidateRequired(configuration, "Messaging:Password", errors);
        }

        if (errors.Count > 0)
        {
            throw new InvalidOperationException(
                "Platform configuration validation failed: " + string.Join(" ", errors));
        }

        return services;
    }

    private static void ValidateRequired(IConfiguration configuration, string key, List<string> errors)
    {
        if (string.IsNullOrWhiteSpace(configuration[key]))
        {
            errors.Add($"Missing required configuration key '{key}'.");
        }
    }
}
