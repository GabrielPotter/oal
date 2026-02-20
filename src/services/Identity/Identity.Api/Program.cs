using BuildingBlocks.Auth;
using BuildingBlocks.Authorization;
using BuildingBlocks.Communication;
using BuildingBlocks.Encryption;
using BuildingBlocks.Messaging;
using BuildingBlocks.Observability;
using BuildingBlocks.Persistence;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();
builder.Services.AddPlatformCommunication();
builder.Services.AddPlatformEncryption(builder.Configuration);
builder.Services.AddPlatformPersistence(builder.Configuration);
builder.Services.AddPlatformMessaging(builder.Configuration);
builder.Services.AddPlatformAuthentication(builder.Configuration);
builder.Services.AddPlatformAuthorization(builder.Configuration);
builder.Services.AddPlatformObservability(builder.Configuration);

var app = builder.Build();

app.UsePlatformObservability();
app.UsePlatformCommunication();
app.UseAuthentication();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapHealthChecks("/health/ready");
app.MapGet("/health/live", () => Results.Ok(new { status = "live" }));
app.MapGet("/version", () => Results.Ok(new { service = "Identity.Api", version = "0.1.0" }));

app.MapGet("/api/ping/secure", (HttpContext context) =>
    Results.Ok(new
    {
        message = "secure-ping",
        service = "Identity.Api",
        sub = context.User.FindFirst("sub")?.Value ?? "unknown"
    }))
    .RequireAuthorization(PlatformAuthorizationExtensions.DefaultApiPolicy);

app.Run();
