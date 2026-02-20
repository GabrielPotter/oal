export type AuthUser = {
  sub: string
  email?: string
  displayName?: string
  tenantId?: string
  roles: string[]
  scopes: string[]
}

export type TenantContext = {
  tenantId: string
}

export type AuthSession = {
  accessToken: string
  isAuthenticated: boolean
  user?: AuthUser
  tenant?: TenantContext
}

export type FrontendAuthConfig = {
  authority: string
  realm: string
  clientId: string
  scope: string
  redirectUri: string
  postLogoutRedirectUri: string
  registrationUrl?: string
}

export type FrontendBootstrap = {
  message: string
  tenantId?: string
  features: Record<string, boolean>
}
