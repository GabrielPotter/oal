#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <ServiceName>"
  echo "Example: $0 Orders"
  exit 1
fi

SERVICE_NAME="$1"
if ! [[ "$SERVICE_NAME" =~ ^[A-Z][A-Za-z0-9]+$ ]]; then
  echo "Service name must be PascalCase, example: Orders"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SERVICE_DIR="$REPO_ROOT/src/services/$SERVICE_NAME"
API_NAME="$SERVICE_NAME.Api"
TEST_NAME="$SERVICE_NAME.Tests"
SOLUTION_FILE="$REPO_ROOT/microservices.sln"

if [[ -d "$SERVICE_DIR" ]]; then
  echo "Service directory already exists: $SERVICE_DIR"
  exit 1
fi

export DOTNET_CLI_HOME="${DOTNET_CLI_HOME:-$REPO_ROOT/.dotnet-home}"

echo "Creating service projects under $SERVICE_DIR"
dotnet new webapi -n "$API_NAME" -o "$SERVICE_DIR/$API_NAME" --no-https
dotnet new xunit -n "$TEST_NAME" -o "$SERVICE_DIR/$TEST_NAME"

echo "Adding project references to building blocks"
dotnet add "$SERVICE_DIR/$API_NAME/$API_NAME.csproj" reference \
  "$REPO_ROOT/src/building-blocks/BuildingBlocks.Auth/BuildingBlocks.Auth.csproj" \
  "$REPO_ROOT/src/building-blocks/BuildingBlocks.Authorization/BuildingBlocks.Authorization.csproj" \
  "$REPO_ROOT/src/building-blocks/BuildingBlocks.Communication/BuildingBlocks.Communication.csproj" \
  "$REPO_ROOT/src/building-blocks/BuildingBlocks.Encryption/BuildingBlocks.Encryption.csproj" \
  "$REPO_ROOT/src/building-blocks/BuildingBlocks.Messaging/BuildingBlocks.Messaging.csproj" \
  "$REPO_ROOT/src/building-blocks/BuildingBlocks.Persistence/BuildingBlocks.Persistence.csproj" \
  "$REPO_ROOT/src/building-blocks/BuildingBlocks.Observability/BuildingBlocks.Observability.csproj"

echo "Adding projects to solution"
dotnet sln "$SOLUTION_FILE" add \
  "$SERVICE_DIR/$API_NAME/$API_NAME.csproj" \
  "$SERVICE_DIR/$TEST_NAME/$TEST_NAME.csproj"

cat > "$SERVICE_DIR/$API_NAME/Program.cs" <<EOF
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
app.MapGet("/version", () => Results.Ok(new { service = "$API_NAME", version = "0.1.0" }));

app.MapGet("/api/ping/secure", (HttpContext context) =>
    Results.Ok(new
    {
        message = "secure-ping",
        service = "$API_NAME",
        sub = context.User.FindFirst("sub")?.Value ?? "unknown"
    }))
    .RequireAuthorization(PlatformAuthorizationExtensions.DefaultApiPolicy);

app.Run();
EOF

cat > "$SERVICE_DIR/$API_NAME/appsettings.json" <<EOF
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "Authentication": {
    "Issuer": "oal.identity",
    "Audience": "oal.api",
    "SigningKey": "dev-signing-key-change-me",
    "RequireHttpsMetadata": false
  },
  "Authorization": {
    "RequiredScope": "oal.api"
  },
  "Persistence": {
    "Provider": "postgres",
    "ConnectionString": "Host=localhost;Port=5432;Database=oal;Username=oal;Password=oal"
  },
  "Messaging": {
    "Broker": "rabbitmq",
    "Host": "localhost",
    "Port": 5672,
    "Username": "oal",
    "Password": "oal",
    "VirtualHost": "/",
    "Exchange": "oal.events"
  },
  "Encryption": {
    "ApplicationName": "oal-platform"
  },
  "AllowedHosts": "*"
}
EOF

echo "Service '$SERVICE_NAME' created."
echo "Next steps:"
echo "  dotnet restore \"$SOLUTION_FILE\""
echo "  dotnet build \"$SOLUTION_FILE\" --no-restore -m:1"
