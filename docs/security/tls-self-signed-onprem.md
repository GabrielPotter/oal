# Self-Signed TLS for On-Prem and Test

## Purpose

Provide HTTPS testing for local development and on-prem style environments without a public CA-issued certificate.

## Scope

In scope:
- Dev kind/local-cluster HTTPS with trusted local CA.
- Local CA setup.
- Leaf certificate generation.
- Nginx TLS mounting and validation.

Out of scope:
- Production certificate lifecycle with public trust chains.

## Baseline Assumptions

- Linux host with `openssl`, `docker`, and `docker compose`.
- Hostname mapping via `/etc/hosts` for test domains.

## Concrete Commands and Examples

Define local hostnames:

```sh
echo "127.0.0.1 app.local id.local" | sudo tee -a /etc/hosts
```

Generate a local CA and leaf certificates:

```sh
mkdir -p infra/certs/selfsigned
./infra/certs/selfsigned/generate-selfsigned.sh
```

Start on-prem stack with self-signed override:

```sh
docker compose \
  -f infra/environments/onprem/docker/compose/stack.bootstrap.yml \
  -f infra/environments/onprem/docker/compose/stack.onprem-selfsigned.yml \
  up --build -d
```

Validate chain and HTTPS:

```sh
openssl s_client -connect app.local:443 -servername app.local </dev/null | openssl x509 -noout -issuer -subject
curl --cacert infra/certs/selfsigned/ca/rootCA.crt -I https://app.local
```

Dev kind with local-CA profile:

```sh
DEV_EDGE_TLS_CERT_FILE=infra/certs/selfsigned/app.local/app.local.crt \
DEV_EDGE_TLS_KEY_FILE=infra/certs/selfsigned/app.local/app.local.key \
infra/lifecycle/run/run-dev.sh up --mode k8s --tls local-ca
```

## Failure Modes and Troubleshooting

- Browser still shows certificate error: import root CA into OS/browser trust store.
- TLS hostname mismatch: regenerate cert with matching SAN/CN.
- Keycloak auth metadata errors: align authority URLs with test hostnames.

## Related

- `docs/security/encryption.md`
- `docs/operations/runbook-local-dev.md`
- `docs/runtime/environments.md`

## Last Review

- Date: February 21, 2026
- Owner role: Security Architect
