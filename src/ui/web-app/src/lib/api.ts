export class ApiError extends Error {
  readonly status: number

  constructor(status: number, message: string) {
    super(message)
    this.status = status
  }
}

export async function apiFetch<T>(url: string, token?: string): Promise<T> {
  const correlationId = crypto.randomUUID()
  const response = await fetch(url, {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      'X-Correlation-Id': correlationId,
      Accept: 'application/json',
    },
  })

  if (!response.ok) {
    const message = await safeReadError(response)
    throw new ApiError(response.status, message)
  }

  return (await response.json()) as T
}

async function safeReadError(response: Response): Promise<string> {
  try {
    const body = await response.text()
    return body || `Request failed with status ${response.status}`
  } catch {
    return `Request failed with status ${response.status}`
  }
}
