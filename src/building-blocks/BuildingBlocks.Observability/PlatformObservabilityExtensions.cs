using System.Diagnostics;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace BuildingBlocks.Observability;

public static class PlatformObservabilityExtensions
{
    public static IServiceCollection AddPlatformObservability(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddHealthChecks();
        services.AddProblemDetails();
        return services;
    }

    public static IApplicationBuilder UsePlatformObservability(this IApplicationBuilder app)
    {
        app.UseExceptionHandler();
        app.UseMiddleware<RequestLoggingMiddleware>();
        return app;
    }
}

internal sealed class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task Invoke(HttpContext context)
    {
        var sw = Stopwatch.StartNew();
        await _next(context);
        sw.Stop();

        _logger.LogInformation(
            "HTTP {Method} {Path} -> {StatusCode} in {ElapsedMs} ms",
            context.Request.Method,
            context.Request.Path,
            context.Response.StatusCode,
            sw.ElapsedMilliseconds);
    }
}
