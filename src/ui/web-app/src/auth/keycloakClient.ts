import Keycloak from 'keycloak-js'
import { apiFetch } from '../lib/api'
import type { FrontendAuthConfig } from '../types/auth'

let keycloak: Keycloak | null = null
let config: FrontendAuthConfig | null = null

export async function initAuth(pathname: string): Promise<{ keycloak: Keycloak; config: FrontendAuthConfig; authenticated: boolean }> {
  config = await apiFetch<FrontendAuthConfig>('/api/frontend/auth/config')
  keycloak = new Keycloak({
    url: config.authority,
    realm: config.realm,
    clientId: config.clientId,
  })

  const authenticated = await keycloak.init({
    onLoad: pathname === '/app' ? 'login-required' : 'check-sso',
    pkceMethod: 'S256',
    checkLoginIframe: false,
    redirectUri: config.redirectUri,
  })

  return { keycloak, config, authenticated }
}

export function getAuth(): { keycloak: Keycloak; config: FrontendAuthConfig } {
  if (!keycloak || !config) {
    throw new Error('Auth is not initialized')
  }
  return { keycloak, config }
}
