using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

namespace BuildingBlocks.Messaging;

public static class PlatformMessagingExtensions
{
    public static IServiceCollection AddPlatformMessaging(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.Configure<MessagingOptions>(configuration.GetSection(MessagingOptions.SectionName));
        services.AddSingleton<IMessagePublisher>(provider =>
        {
            var options = provider.GetRequiredService<IOptions<MessagingOptions>>().Value;
            var loggerFactory = provider.GetRequiredService<ILoggerFactory>();

            if (options.Broker.Equals("rabbitmq", StringComparison.OrdinalIgnoreCase))
            {
                return new RabbitMqMessagePublisher(
                    Options.Create(options),
                    loggerFactory.CreateLogger<RabbitMqMessagePublisher>());
            }

            return new NoOpMessagePublisher(loggerFactory.CreateLogger<NoOpMessagePublisher>());
        });

        services.AddHealthChecks()
            .AddCheck<MessagingHealthCheck>("messaging");

        return services;
    }
}

public sealed class MessagingOptions
{
    public const string SectionName = "Messaging";
    public string Broker { get; init; } = "rabbitmq";
    public string Host { get; init; } = "localhost";
    public int Port { get; init; } = 5672;
    public string Username { get; init; } = "oal";
    public string Password { get; init; } = "oal";
    public string VirtualHost { get; init; } = "/";
    public string Exchange { get; init; } = "oal.events";
}

public interface IMessagePublisher
{
    Task PublishAsync<T>(string topic, T message, CancellationToken cancellationToken = default);
}

internal sealed class NoOpMessagePublisher : IMessagePublisher
{
    private readonly ILogger<NoOpMessagePublisher> _logger;

    public NoOpMessagePublisher(ILogger<NoOpMessagePublisher> logger)
    {
        _logger = logger;
    }

    public Task PublishAsync<T>(string topic, T message, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("NoOp publish to topic {Topic}. MessageType: {MessageType}", topic, typeof(T).Name);
        return Task.CompletedTask;
    }
}

internal sealed class RabbitMqMessagePublisher : IMessagePublisher, IDisposable
{
    private readonly IOptions<MessagingOptions> _options;
    private readonly ILogger<RabbitMqMessagePublisher> _logger;
    private readonly object _sync = new();
    private IConnection? _connection;
    private IModel? _channel;

    public RabbitMqMessagePublisher(
        IOptions<MessagingOptions> options,
        ILogger<RabbitMqMessagePublisher> logger)
    {
        _options = options;
        _logger = logger;
    }

    public Task PublishAsync<T>(string topic, T message, CancellationToken cancellationToken = default)
    {
        EnsureConnected();
        var options = _options.Value;

        var payload = JsonSerializer.Serialize(message);
        var body = Encoding.UTF8.GetBytes(payload);
        var exchange = options.Exchange;

        if (string.IsNullOrWhiteSpace(exchange))
        {
            _channel!.QueueDeclare(topic, durable: true, exclusive: false, autoDelete: false);
            exchange = string.Empty;
        }
        else
        {
            _channel!.ExchangeDeclare(exchange, ExchangeType.Topic, durable: true);
        }

        var properties = _channel!.CreateBasicProperties();
        properties.ContentType = "application/json";
        properties.DeliveryMode = 2;

        _channel.BasicPublish(
            exchange: exchange,
            routingKey: topic,
            basicProperties: properties,
            body: body);

        _logger.LogInformation("Published message to {Topic} via {Exchange}", topic, exchange);
        return Task.CompletedTask;
    }

    public void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
    }

    private void EnsureConnected()
    {
        if (_connection?.IsOpen == true && _channel is not null)
        {
            return;
        }

        lock (_sync)
        {
            if (_connection?.IsOpen == true && _channel is not null)
            {
                return;
            }

            var options = _options.Value;
            var factory = new ConnectionFactory
            {
                HostName = options.Host,
                Port = options.Port,
                UserName = options.Username,
                Password = options.Password,
                VirtualHost = options.VirtualHost
            };

            _connection?.Dispose();
            _channel?.Dispose();
            _connection = factory.CreateConnection("oal-platform-publisher");
            _channel = _connection.CreateModel();
        }
    }
}

internal sealed class MessagingHealthCheck : IHealthCheck
{
    private readonly IOptions<MessagingOptions> _options;

    public MessagingHealthCheck(IOptions<MessagingOptions> options)
    {
        _options = options;
    }

    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var options = _options.Value;
        if (!options.Broker.Equals("rabbitmq", StringComparison.OrdinalIgnoreCase))
        {
            return Task.FromResult(HealthCheckResult.Healthy("Non-RabbitMQ broker configured; skipping check."));
        }

        if (string.IsNullOrWhiteSpace(options.Host) || options.Port <= 0)
        {
            return Task.FromResult(HealthCheckResult.Unhealthy("Messaging host/port configuration is missing."));
        }

        try
        {
            var factory = new ConnectionFactory
            {
                HostName = options.Host,
                Port = options.Port,
                UserName = options.Username,
                Password = options.Password,
                VirtualHost = options.VirtualHost
            };

            using var connection = factory.CreateConnection("oal-platform-healthcheck");
            return Task.FromResult(connection.IsOpen
                ? HealthCheckResult.Healthy("RabbitMQ connection opened successfully.")
                : HealthCheckResult.Unhealthy("RabbitMQ connection could not be opened."));
        }
        catch (Exception ex)
        {
            return Task.FromResult(HealthCheckResult.Unhealthy("RabbitMQ connectivity check failed.", ex));
        }
    }
}
