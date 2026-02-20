using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BuildingBlocks.Encryption;

public static class PlatformEncryptionExtensions
{
    public static IServiceCollection AddPlatformEncryption(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var appName = configuration["Encryption:ApplicationName"] ?? "oal-platform";
        services.AddDataProtection().SetApplicationName(appName);
        return services;
    }
}
