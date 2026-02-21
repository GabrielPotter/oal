#!/usr/bin/env bash
# Purpose:
#   Install or upgrade all required developer tools for OAL on Ubuntu 24.04.
# Inputs:
#   - Interactive confirmations per missing dependency (Install? y/N)
# Outputs:
#   - Installed/updated toolchain for local development and runtime workflows.
# Preconditions:
#   - Ubuntu 24.04 host
#   - sudo privileges available for package/repository operations
# Failure modes:
#   - exits non-zero only for hard preconditions (non-Ubuntu, missing sudo, apt failure)
#   - skips tools when user answers no
# Examples:
#   - bash infra/lifecycle/prerequisites/install-dev-ubuntu24.sh
#   - bash infra/lifecycle/prerequisites/install-dev-ubuntu24.sh
# Security notes:
#   - Script installs software from official vendor repositories.
#   - Never stores project secrets.
set -euo pipefail

log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_err() { echo "[ERROR] $*"; }

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_err "Required command '$cmd' is missing."
    exit 1
  fi
}

confirm_install() {
  local question="$1"
  local answer=""
  read -r -p "$question [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

ensure_ubuntu_24() {
  if [[ ! -f /etc/os-release ]]; then
    log_err "Cannot detect OS. /etc/os-release is missing."
    exit 1
  fi

  # shellcheck source=/dev/null
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    log_err "This script only supports Ubuntu 24.04. Detected ID='${ID:-unknown}'."
    exit 1
  fi

  if [[ "${VERSION_ID:-}" != "24.04" ]]; then
    log_warn "Detected Ubuntu ${VERSION_ID:-unknown}. This script is tuned for 24.04."
    if ! confirm_install "Continue anyway?"; then
      exit 1
    fi
  fi
}

apt_update_once() {
  if [[ "${APT_UPDATED:-0}" == "1" ]]; then
    return
  fi

  sudo apt-get update
  APT_UPDATED=1
}

install_apt_packages() {
  local packages=("$@")
  apt_update_once
  sudo apt-get install -y "${packages[@]}"
}

install_base_utilities() {
  local required=(bash git curl jq ca-certificates gnupg lsb-release unzip tar)
  local missing=()

  for cmd in "${required[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    log_info "Base utilities already installed."
    return
  fi

  log_warn "Missing base utilities: ${missing[*]}"
  if confirm_install "Install missing base utilities?"; then
    install_apt_packages "${missing[@]}"
  else
    log_warn "Skipped base utility installation."
  fi
}

ensure_docker() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    log_info "Docker Engine and Compose plugin are already available."
    return
  fi

  log_warn "Docker Engine and/or Docker Compose plugin is missing."
  if ! confirm_install "Install/upgrade Docker Engine + Compose plugin?"; then
    log_warn "Skipped Docker installation."
    return
  fi

  install_apt_packages ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
  fi

  local arch
  arch="$(dpkg --print-architecture)"
  local codename
  # shellcheck source=/dev/null
  source /etc/os-release
  codename="${VERSION_CODENAME:-noble}"

  cat <<REPO | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
Deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable
REPO

  apt_update_once
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  log_info "Docker installation complete."
  if groups "$USER" | grep -q '\bdocker\b'; then
    log_info "User '$USER' is already in docker group."
  else
    log_warn "User '$USER' is not in docker group. You may need: sudo usermod -aG docker $USER"
  fi
}

ensure_dotnet() {
  if command -v dotnet >/dev/null 2>&1; then
    if dotnet --list-sdks 2>/dev/null | grep -q '^10\.'; then
      log_info ".NET SDK 10.x is already installed."
      return
    fi
  fi

  log_warn ".NET SDK 10.x is missing."
  if ! confirm_install "Install/upgrade .NET SDK 10 via Microsoft apt repository?"; then
    log_warn "Skipped .NET SDK installation."
    return
  fi

  install_apt_packages wget gnupg apt-transport-https
  if [[ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]]; then
    wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
    sudo dpkg -i /tmp/packages-microsoft-prod.deb
    rm -f /tmp/packages-microsoft-prod.deb
  fi

  apt_update_once
  sudo apt-get install -y dotnet-sdk-10.0
  log_info ".NET SDK installation complete."
}

ensure_node() {
  local has_node=0
  local has_npm=0

  if command -v node >/dev/null 2>&1; then has_node=1; fi
  if command -v npm >/dev/null 2>&1; then has_npm=1; fi

  if [[ "$has_node" == "1" && "$has_npm" == "1" ]]; then
    log_info "Node and npm are already installed."
    return
  fi

  log_warn "Node and/or npm is missing."
  if ! confirm_install "Install/upgrade Node.js 22.x + npm?"; then
    log_warn "Skipped Node.js installation."
    return
  fi

  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  install_apt_packages nodejs
  log_info "Node.js installation complete."
}

ensure_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    log_info "kubectl is already installed."
    return
  fi

  log_warn "kubectl is missing."
  if ! confirm_install "Install/upgrade kubectl?"; then
    log_warn "Skipped kubectl installation."
    return
  fi

  install_apt_packages apt-transport-https ca-certificates curl gnupg
  sudo mkdir -p -m 755 /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]]; then
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
      | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  fi

  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

  apt_update_once
  sudo apt-get install -y kubectl
  log_info "kubectl installation complete."
}

ensure_kind() {
  if command -v kind >/dev/null 2>&1; then
    log_info "kind is already installed."
    return
  fi

  log_warn "kind is missing."
  if ! confirm_install "Install/upgrade kind?"; then
    log_warn "Skipped kind installation."
    return
  fi

  local arch
  arch="$(uname -m)"
  local kind_arch="amd64"
  if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
    kind_arch="arm64"
  fi

  curl -Lo /tmp/kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-${kind_arch}
  chmod +x /tmp/kind
  sudo mv /tmp/kind /usr/local/bin/kind
  log_info "kind installation complete."
}

ensure_kustomize() {
  if command -v kustomize >/dev/null 2>&1; then
    log_info "kustomize is already installed."
    return
  fi

  if command -v kubectl >/dev/null 2>&1 && kubectl kustomize --help >/dev/null 2>&1; then
    log_info "kubectl kustomize is available; standalone kustomize is optional."
    return
  fi

  log_warn "kustomize is missing."
  if ! confirm_install "Install/upgrade standalone kustomize?"; then
    log_warn "Skipped kustomize installation."
    return
  fi

  local version="v5.4.3"
  local arch
  arch="$(uname -m)"
  local k_arch="amd64"
  if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
    k_arch="arm64"
  fi

  local tarball="kustomize_${version#v}_linux_${k_arch}.tar.gz"
  curl -Lo "/tmp/${tarball}" "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${version}/${tarball}"
  tar -xzf "/tmp/${tarball}" -C /tmp
  sudo mv /tmp/kustomize /usr/local/bin/kustomize
  sudo chmod +x /usr/local/bin/kustomize
  rm -f "/tmp/${tarball}"
  log_info "kustomize installation complete."
}

print_summary() {
  echo
  echo "===== Toolchain summary ====="
  command -v dotnet >/dev/null 2>&1 && dotnet --version || echo "dotnet: missing"
  command -v node >/dev/null 2>&1 && node --version || echo "node: missing"
  command -v npm >/dev/null 2>&1 && npm --version || echo "npm: missing"
  command -v docker >/dev/null 2>&1 && docker --version || echo "docker: missing"
  if command -v docker >/dev/null 2>&1; then
    docker compose version || true
  fi
  command -v kubectl >/dev/null 2>&1 && kubectl version --client --short 2>/dev/null || echo "kubectl: missing"
  command -v kind >/dev/null 2>&1 && kind version || echo "kind: missing"
  if command -v kustomize >/dev/null 2>&1; then
    kustomize version || true
  else
    echo "kustomize: missing (or use kubectl kustomize)"
  fi
}

main() {
  require_cmd sudo
  ensure_ubuntu_24
  install_base_utilities
  ensure_docker
  ensure_dotnet
  ensure_node
  ensure_kubectl
  ensure_kind
  ensure_kustomize
  print_summary

  echo
  echo "Run verification after installation:"
  echo "  bash infra/lifecycle/prerequisites/check-install.sh --target dev --mode check-only"
  echo "  bash infra/lifecycle/verify/verify-dotnet.sh"
  echo "  bash infra/lifecycle/verify/verify-all.sh --target all"
}

main "$@"
