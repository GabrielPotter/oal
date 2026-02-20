using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BuildingBlocks.Authorization;

public static class PlatformAuthorizationExtensions {
    public const string DefaultApiPolicy = "PlatformApi";
    public const string TenantRequiredPolicy = "TenantRequired";

    public static IServiceCollection AddPlatformAuthorization(
        this IServiceCollection services,
        IConfiguration configuration) {
        var requiredScope = configuration["Authorization:RequiredScope"] ?? "oal.api";
        var tenantClaim = configuration["Authorization:TenantClaim"] ?? "tenant_id";

        services.AddAuthorizationBuilder()
            .AddPolicy(DefaultApiPolicy, policy => {
                policy.RequireAuthenticatedUser();
                policy.RequireAssertion(context =>
                    context.User.HasClaim("scope", requiredScope) ||
                    context.User.HasClaim("scp", requiredScope));
            })
            .AddPolicy(TenantRequiredPolicy, policy => {
                policy.RequireAuthenticatedUser();
                policy.RequireClaim(tenantClaim);
            });

        return services;
    }
}
