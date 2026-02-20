using BuildingBlocks.Auth;
using BuildingBlocks.Authorization;
using BuildingBlocks.Communication;
using BuildingBlocks.Encryption;
using BuildingBlocks.Messaging;
using BuildingBlocks.Observability;
using BuildingBlocks.Persistence;
using Gateway.Api.Frontend;
using System.Security.Claims;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();
builder.Services.AddPlatformCommunication();
builder.Services.AddPlatformEncryption(builder.Configuration);
builder.Services.AddPlatformPersistence(builder.Configuration);
builder.Services.AddPlatformMessaging(builder.Configuration);
builder.Services.AddPlatformAuthentication(builder.Configuration);
builder.Services.AddPlatformAuthorization(builder.Configuration);
builder.Services.AddPlatformObservability(builder.Configuration);
builder.Services.Configure<FrontendAuthOptions>(builder.Configuration.GetSection(FrontendAuthOptions.SectionName));
builder.Services.Configure<InternalServicesOptions>(builder.Configuration.GetSection(InternalServicesOptions.SectionName));
builder.Services.AddHttpClient<IInternalServicesClient, InternalServicesClient>();

var allowedOrigins = builder.Configuration.GetSection("Frontend:AllowedOrigins").Get<string[]>() ??
    ["http://localhost:5173", "http://localhost:8080"];
builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendOnly", policy =>
    {
        policy.WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

app.UsePlatformObservability();
app.UsePlatformCommunication();
app.UseCors("FrontendOnly");
app.UseAuthentication();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapHealthChecks("/health/ready");
app.MapGet("/health/live", () => Results.Ok(new { status = "live" }));
app.MapGet("/version", () => Results.Ok(new { service = "Gateway.Api", version = "0.1.0" }));

var frontendGroup = app.MapGroup("/api/frontend");

frontendGroup.MapGet("/auth/config", (IConfiguration configuration) =>
{
    var options = configuration.GetSection(FrontendAuthOptions.SectionName).Get<FrontendAuthOptions>() ?? new FrontendAuthOptions();
    return Results.Ok(options);
});

frontendGroup.MapGet("/registration/url", (IConfiguration configuration) =>
{
    var options = configuration.GetSection(FrontendAuthOptions.SectionName).Get<FrontendAuthOptions>() ?? new FrontendAuthOptions();
    var registrationUrl = string.IsNullOrWhiteSpace(options.RegistrationUrl)
        ? $"{options.Authority}/protocol/openid-connect/registrations?client_id={options.ClientId}&response_type=code&scope={Uri.EscapeDataString(options.Scope)}&redirect_uri={Uri.EscapeDataString(options.RedirectUri)}"
        : options.RegistrationUrl;

    return Results.Ok(new { url = registrationUrl });
});

frontendGroup.MapGet("/me", (HttpContext context) =>
{
    var user = context.User;
    var scopes = ReadScopes(user).ToArray();
    var roles = user.Claims.Where(c => c.Type is ClaimTypes.Role or "role" or "roles").Select(c => c.Value).Distinct().ToArray();
    var tenantId = user.FindFirst("tenant_id")?.Value;

    return Results.Ok(new FrontendMeResponse(
        user.FindFirstValue("sub") ?? string.Empty,
        user.FindFirstValue("email"),
        user.FindFirstValue("name") ?? user.FindFirstValue("preferred_username") ?? user.Identity?.Name,
        tenantId,
        roles,
        scopes));
}).RequireAuthorization(PlatformAuthorizationExtensions.DefaultApiPolicy, PlatformAuthorizationExtensions.TenantRequiredPolicy);

frontendGroup.MapGet("/bootstrap", (HttpContext context) =>
{
    var displayName = context.User.FindFirstValue("name") ??
                      context.User.FindFirstValue("preferred_username") ??
                      context.User.FindFirstValue("email") ??
                      "user";
    var tenantId = context.User.FindFirstValue("tenant_id");
    return Results.Ok(new
    {
        message = $"Welcome {displayName}",
        tenantId,
        features = new { profile = true, notifications = true }
    });
}).RequireAuthorization(PlatformAuthorizationExtensions.DefaultApiPolicy, PlatformAuthorizationExtensions.TenantRequiredPolicy);

frontendGroup.MapGet("/internal/status", async (HttpContext context, IInternalServicesClient internalServicesClient, CancellationToken ct) =>
{
    var statuses = await internalServicesClient.GetServiceStatusAsync(context, ct);
    return Results.Ok(statuses);
}).RequireAuthorization(PlatformAuthorizationExtensions.DefaultApiPolicy, PlatformAuthorizationExtensions.TenantRequiredPolicy);

app.MapGet("/api/ping/secure", (HttpContext context) =>
    Results.Ok(new
    {
        message = "secure-ping",
        service = "Gateway.Api",
        sub = context.User.FindFirst("sub")?.Value ?? "unknown"
    }))
    .RequireAuthorization(PlatformAuthorizationExtensions.DefaultApiPolicy, PlatformAuthorizationExtensions.TenantRequiredPolicy);

app.Run();

static IEnumerable<string> ReadScopes(ClaimsPrincipal user)
{
    return user.Claims
        .Where(c => c.Type is "scope" or "scp")
        .SelectMany(c => c.Value.Split(' ', StringSplitOptions.RemoveEmptyEntries))
        .Distinct();
}

public sealed record FrontendMeResponse(
    string Sub,
    string? Email,
    string? DisplayName,
    string? TenantId,
    string[] Roles,
    string[] Scopes);

public sealed class FrontendAuthOptions
{
    public const string SectionName = "FrontendAuth";
    public string Authority { get; init; } = "http://localhost:8088/realms/oal";
    public string Realm { get; init; } = "oal";
    public string ClientId { get; init; } = "web-app";
    public string Scope { get; init; } = "openid profile email";
    public string RedirectUri { get; init; } = "http://localhost:5173/app";
    public string PostLogoutRedirectUri { get; init; } = "http://localhost:5173/login";
    public string RegistrationUrl { get; init; } = string.Empty;
}
