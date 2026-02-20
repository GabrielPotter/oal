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
        var audience = configuration["Authentication:Audience"] ?? "oal.api";
        var issuer = configuration["Authentication:Issuer"] ?? "oal.identity";
        var signingKey = configuration["Authentication:SigningKey"] ?? "dev-signing-key-change-me";
        var requireHttpsMetadata = configuration.GetValue("Authentication:RequireHttpsMetadata", false);

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
