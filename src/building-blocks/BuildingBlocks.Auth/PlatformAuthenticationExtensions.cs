using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace BuildingBlocks.Auth;

public static class PlatformAuthenticationExtensions {
    public static IServiceCollection AddPlatformAuthentication(
        this IServiceCollection services,
        IConfiguration configuration) {
        var authority = configuration["Authentication:Authority"];
        var audience = configuration["Authentication:Audience"];
        var issuer = configuration["Authentication:Issuer"];
        var signingKey = configuration["Authentication:SigningKey"];
        var requireHttpsMetadata = configuration.GetValue("Authentication:RequireHttpsMetadata", true);

        if (string.IsNullOrWhiteSpace(audience)) {
            throw new InvalidOperationException("Missing required configuration key 'Authentication:Audience'.");
        }

        services
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options => {
                options.RequireHttpsMetadata = requireHttpsMetadata;
                options.Audience = audience;
                options.MapInboundClaims = false;

                if (!string.IsNullOrWhiteSpace(authority)) {
                    options.Authority = authority;
                    return;
                }

                if (string.IsNullOrWhiteSpace(issuer) || string.IsNullOrWhiteSpace(signingKey)) {
                    throw new InvalidOperationException(
                        "When 'Authentication:Authority' is not configured, both 'Authentication:Issuer' and " +
                        "'Authentication:SigningKey' must be provided.");
                }

                options.TokenValidationParameters = new TokenValidationParameters {
                    ValidateIssuer = true,
                    ValidIssuer = issuer,
                    ValidateAudience = true,
                    ValidAudience = audience,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromSeconds(30),
                    NameClaimType = "sub",
                    RoleClaimType = "role"
                };
            });

        return services;
    }
}
