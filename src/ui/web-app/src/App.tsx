import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { getAuth, initAuth } from './auth/keycloakClient'
import { ApiError, apiFetch } from './lib/api'
import type { AuthSession, AuthUser, FrontendBootstrap } from './types/auth'

type RoutePath = '/login' | '/register' | '/app'

export default function App(): JSX.Element {
  const [route, setRoute] = useState<RoutePath>(normalizeRoute(window.location.pathname))
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [session, setSession] = useState<AuthSession>({ accessToken: '', isAuthenticated: false })
  const [bootstrap, setBootstrap] = useState<FrontendBootstrap | null>(null)

  useEffect(() => {
    const onPopState = () => setRoute(normalizeRoute(window.location.pathname))
    window.addEventListener('popstate', onPopState)
    return () => window.removeEventListener('popstate', onPopState)
  }, [])

  useEffect(() => {
    let active = true
    ;(async () => {
      try {
        setLoading(true)
        const { keycloak, authenticated } = await initAuth(route)
        if (!active) return

        if (!authenticated) {
          setSession({ accessToken: '', isAuthenticated: false })
          if (route === '/app') navigate('/login', setRoute)
          return
        }

        const token = keycloak.token ?? ''
        const user = await apiFetch<AuthUser>('/api/frontend/me', token)
        const boot = await apiFetch<FrontendBootstrap>('/api/frontend/bootstrap', token)
        if (!active) return

        setSession({
          accessToken: token,
          isAuthenticated: true,
          user,
          tenant: user.tenantId ? { tenantId: user.tenantId } : undefined,
        })
        setBootstrap(boot)
        if (route !== '/app') navigate('/app', setRoute)
      } catch (e) {
        if (!active) return
        if (e instanceof ApiError && (e.status === 401 || e.status === 403)) {
          setSession({ accessToken: '', isAuthenticated: false })
          navigate('/login', setRoute)
        } else {
          setError(e instanceof Error ? e.message : 'Unknown error')
        }
      } finally {
        if (active) setLoading(false)
      }
    })()

    return () => {
      active = false
    }
  }, [route])

  const welcome = useMemo(() => bootstrap?.message ?? 'Welcome', [bootstrap?.message])

  if (loading) {
    return <Centered>Loading...</Centered>
  }

  if (error) {
    return <Centered>Error: {error}</Centered>
  }

  if (route === '/register') {
    return (
      <Centered>
        <h1>Registration</h1>
        <p>Redirecting to identity provider registration page...</p>
      </Centered>
    )
  }

  if (route === '/app' && session.isAuthenticated && session.user) {
    return (
      <main style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
        <h1>Main Window</h1>
        <p>{welcome}</p>
        <p>User: {session.user.displayName ?? session.user.email ?? session.user.sub}</p>
        <p>Tenant: {session.user.tenantId ?? 'n/a'}</p>
        <p>Scopes: {session.user.scopes.join(', ')}</p>
        <button onClick={logout}>Logout</button>
      </main>
    )
  }

  return (
    <main style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>Login</h1>
      <p>Sign in to access the multi-tenant platform.</p>
      <div style={{ display: 'flex', gap: '0.75rem' }}>
        <button onClick={login}>Login with Keycloak</button>
        <button onClick={() => register(setRoute)}>Register</button>
      </div>
    </main>
  )
}

function normalizeRoute(path: string): RoutePath {
  if (path === '/app' || path === '/register' || path === '/login') return path
  return '/login'
}

function navigate(path: RoutePath, setRoute: (route: RoutePath) => void): void {
  window.history.pushState({}, '', path)
  setRoute(path)
}

async function login(): Promise<void> {
  const { keycloak, config } = getAuth()
  await keycloak.login({ redirectUri: config.redirectUri })
}

async function register(setRoute: (route: RoutePath) => void): Promise<void> {
  setRoute('/register')
  const response = await apiFetch<{ url: string }>('/api/frontend/registration/url')
  window.location.href = response.url
}

async function logout(): Promise<void> {
  const { keycloak, config } = getAuth()
  await keycloak.logout({ redirectUri: config.postLogoutRedirectUri })
}

function Centered({ children }: { children: ReactNode }): JSX.Element {
  return (
    <main style={{ fontFamily: 'sans-serif', padding: '2rem', display: 'grid', placeItems: 'center', minHeight: '100vh' }}>
      <div>{children}</div>
    </main>
  )
}
