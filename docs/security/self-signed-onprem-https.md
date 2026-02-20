# Self-Signed TLS for On-Prem/Test

This guide explains how to run the platform with HTTPS when you do not have a public/valid domain.

Scope:
- Create your own local CA.
- Issue server certificates (for example `app.local` and `id.local`).
- Mount certificate to Nginx.
- Trust CA in browser and OS.
- Validate HTTPS end-to-end.

## 1. Prerequisites

- Linux host.
- `openssl` installed.
- `docker` and `docker compose` installed.
- Root/sudo access for trust store updates and `/etc/hosts` edits.

Check:

```bash
openssl version
docker --version
docker compose version
```

## 2. Define test hostnames

Use local hostnames instead of raw IP:
- `app.local` for web app edge.
- `id.local` for Keycloak (optional but recommended).

Add to `/etc/hosts`:

```bash
echo "127.0.0.1 app.local id.local" | sudo tee -a /etc/hosts
```

## 3. Create local CA and issue certs

Create script:

```bash
mkdir -p infra/certs/selfsigned
cat > infra/certs/selfsigned/generate-selfsigned.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="infra/certs/selfsigned"
CA_DIR="$BASE_DIR/ca"

mkdir -p "$CA_DIR" "$BASE_DIR/app.local" "$BASE_DIR/id.local"

# 1) Root CA
openssl genrsa -out "$CA_DIR/rootCA.key" 4096
openssl req -x509 -new -nodes \
  -key "$CA_DIR/rootCA.key" \
  -sha256 -days 3650 \
  -out "$CA_DIR/rootCA.crt" \
  -subj "/C=US/ST=Test/L=Test/O=OAL Dev/CN=OAL Dev Root CA"

issue_cert () {
  local NAME="$1"
  local DIR="$BASE_DIR/$NAME"

  openssl genrsa -out "$DIR/$NAME.key" 2048
  openssl req -new -key "$DIR/$NAME.key" \
    -out "$DIR/$NAME.csr" \
    -subj "/C=US/ST=Test/L=Test/O=OAL Dev/CN=$NAME"

  cat > "$DIR/$NAME.ext" <<EOT
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = $NAME
EOT

  openssl x509 -req \
    -in "$DIR/$NAME.csr" \
    -CA "$CA_DIR/rootCA.crt" \
    -CAkey "$CA_DIR/rootCA.key" \
    -CAcreateserial \
    -out "$DIR/$NAME.crt" \
    -days 825 -sha256 \
    -extfile "$DIR/$NAME.ext"
}

issue_cert "app.local"
issue_cert "id.local"

echo "Generated:"
echo "  CA:        $CA_DIR/rootCA.crt"
echo "  app cert:  $BASE_DIR/app.local/app.local.crt"
echo "  app key:   $BASE_DIR/app.local/app.local.key"
echo "  id cert:   $BASE_DIR/id.local/id.local.crt"
echo "  id key:    $BASE_DIR/id.local/id.local.key"
EOF

chmod +x infra/certs/selfsigned/generate-selfsigned.sh
./infra/certs/selfsigned/generate-selfsigned.sh
```

## 4. Install CA into Linux trust store

Debian/Ubuntu:

```bash
sudo cp infra/certs/selfsigned/ca/rootCA.crt /usr/local/share/ca-certificates/oal-dev-rootCA.crt
sudo update-ca-certificates
```

RHEL/CentOS/Fedora:

```bash
sudo cp infra/certs/selfsigned/ca/rootCA.crt /etc/pki/ca-trust/source/anchors/oal-dev-rootCA.crt
sudo update-ca-trust
```

## 5. Configure Nginx for self-signed cert

Create TLS config:

```bash
cat > infra/nginx/default-https-selfsigned.conf <<'EOF'
server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name _;

    ssl_certificate /etc/nginx/certs/app.local.crt;
    ssl_certificate_key /etc/nginx/certs/app.local.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://gateway-api:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Correlation-Id $request_id;
    }
}
EOF
```

## 6. Start stack with self-signed cert mounted

Create compose override:

```bash
cat > infra/docker/compose/docker-compose.onprem-selfsigned.yml <<'EOF'
services:
  web-nginx:
    volumes:
      - ../../nginx/default-https-selfsigned.conf:/etc/nginx/conf.d/default.conf:ro
      - ../../certs/selfsigned/app.local:/etc/nginx/certs:ro
    ports:
      - "80:80"
      - "443:443"
EOF
```

Run:

```bash
docker compose \
  -f infra/docker/compose/docker-compose.onprem-https.yml \
  -f infra/docker/compose/docker-compose.onprem-selfsigned.yml \
  up --build -d
```

## 7. Browser trust configuration

If OS trust store is updated, Chromium/Chrome usually trust it automatically.

Firefox may require manual import:
1. Open `about:preferences#privacy`
2. Certificates -> View Certificates -> Authorities
3. Import `infra/certs/selfsigned/ca/rootCA.crt`
4. Enable trust for websites

## 8. Validate HTTPS

Certificate chain:

```bash
openssl s_client -connect app.local:443 -servername app.local </dev/null | openssl x509 -noout -issuer -subject
```

HTTP redirect:

```bash
curl -I http://app.local
```

HTTPS content:

```bash
curl --cacert infra/certs/selfsigned/ca/rootCA.crt -I https://app.local
curl --cacert infra/certs/selfsigned/ca/rootCA.crt https://app.local/api/frontend/auth/config
```

## 9. Keycloak note for test mode

If Keycloak is also exposed with self-signed TLS (`https://id.local`), keep these aligned:
- Gateway `Authentication:Authority`
- Gateway `FrontendAuth:Authority`
- Keycloak client redirect/logout URIs

If you cannot trust Keycloak cert yet in test:
- temporary fallback only: `Authentication:RequireHttpsMetadata=false`
- do not use this fallback in production.

## 10. Renewal and rotation

For self-signed/local CA setup there is no automatic LE renewal.
When cert expires:
1. Re-run generation script.
2. Restart/reload Nginx container.
3. Re-import CA only if root CA changed.

Recommended:
- Keep root CA stable.
- Rotate only leaf certs (`app.local`, `id.local`).
