using System.Net.Http.Headers;
using Microsoft.Extensions.Options;

namespace Gateway.Api.Frontend;

public interface IInternalServicesClient
{
    Task<IReadOnlyDictionary<string, bool>> GetServiceStatusAsync(HttpContext context, CancellationToken cancellationToken = default);
}

public sealed class InternalServicesClient : IInternalServicesClient
{
    private readonly HttpClient _httpClient;
    private readonly IOptions<InternalServicesOptions> _options;

    public InternalServicesClient(HttpClient httpClient, IOptions<InternalServicesOptions> options)
    {
        _httpClient = httpClient;
        _options = options;
    }

    public async Task<IReadOnlyDictionary<string, bool>> GetServiceStatusAsync(HttpContext context, CancellationToken cancellationToken = default)
    {
        var result = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        foreach (var service in _options.Value.Services)
        {
            if (string.IsNullOrWhiteSpace(service.Name) || string.IsNullOrWhiteSpace(service.BaseUrl))
            {
                continue;
            }

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Get, $"{service.BaseUrl.TrimEnd('/')}/version");
                if (context.Request.Headers.TryGetValue("Authorization", out var authHeader) && !string.IsNullOrWhiteSpace(authHeader))
                {
                    request.Headers.TryAddWithoutValidation("Authorization", authHeader.ToString());
                }

                if (context.Request.Headers.TryGetValue("X-Correlation-Id", out var correlationId))
                {
                    request.Headers.TryAddWithoutValidation("X-Correlation-Id", correlationId.ToString());
                }

                request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                using var response = await _httpClient.SendAsync(request, cancellationToken);
                result[service.Name] = response.IsSuccessStatusCode;
            }
            catch
            {
                result[service.Name] = false;
            }
        }

        return result;
    }
}

public sealed class InternalServicesOptions
{
    public const string SectionName = "InternalServices";
    public List<InternalServiceTarget> Services { get; init; } = [];
}

public sealed class InternalServiceTarget
{
    public string Name { get; init; } = string.Empty;
    public string BaseUrl { get; init; } = string.Empty;
}
