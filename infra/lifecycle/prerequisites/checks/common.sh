#!/usr/bin/env bash
# Purpose: Common dependency checks and package install helpers shared by all targets.
# Inputs:
#   - CHECK_INSTALL_MODE (optional): interactive|check-only
#   - PACKAGE_MANAGER (optional): auto-detected if not set
# Outputs:
#   - functions used by check-install.sh and target-specific check modules.
# Preconditions:
#   - bash available.
# Failure modes:
#   - returns non-zero when dependency install/check fails.
# Security notes:
#   - package installs may require sudo; script never stores secrets.
set -euo pipefail

REPORT_FILE="${REPORT_FILE:-/tmp/oal-prereq-report.json}"
CHECK_INSTALL_MODE="${CHECK_INSTALL_MODE:-interactive}"

log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_err() { echo "[ERROR] $*"; }

json_escape() {
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/ }
  echo "$s"
}

detect_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then echo "apt"; return; fi
  if command -v dnf >/dev/null 2>&1; then echo "dnf"; return; fi
  if command -v yum >/dev/null 2>&1; then echo "yum"; return; fi
  echo "unknown"
}

PACKAGE_MANAGER="${PACKAGE_MANAGER:-$(detect_package_manager)}"

install_package_cmd() {
  local pkg="$1"
  case "$PACKAGE_MANAGER" in
    apt) echo "sudo apt-get update && sudo apt-get install -y $pkg" ;;
    dnf) echo "sudo dnf install -y $pkg" ;;
    yum) echo "sudo yum install -y $pkg" ;;
    *) echo "" ;;
  esac
}

run_install_cmd() {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    return 1
  fi

  if [[ "$CHECK_INSTALL_MODE" == "check-only" ]]; then
    log_warn "check-only mode: skipping install command: $cmd"
    return 1
  fi

  if [[ "$CHECK_INSTALL_MODE" == "interactive" ]]; then
    read -r -p "Install now? [y/N]: " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      return 1
    fi
  fi

  bash -lc "$cmd"
}

check_or_install_cmd() {
  local cmd="$1"
  local pkg="$2"
  local reason="$3"

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "{\"name\":\"$(json_escape "$cmd")\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
    log_info "$cmd detected"
    return 0
  fi

  local install_cmd
  install_cmd=$(install_package_cmd "$pkg")
  log_warn "$cmd missing ($reason)"
  if [[ -n "$install_cmd" ]]; then
    log_info "Suggested install: $install_cmd"
  else
    log_warn "No supported package manager found. Install manually."
  fi

  if run_install_cmd "$install_cmd" && command -v "$cmd" >/dev/null 2>&1; then
    echo "{\"name\":\"$(json_escape "$cmd")\",\"status\":\"pass\",\"reason\":\"installed-by-script\"}" >> "$REPORT_TMP"
    log_info "$cmd installed successfully"
    return 0
  fi

  echo "{\"name\":\"$(json_escape "$cmd")\",\"status\":\"fail\",\"reason\":\"missing\",\"install\":\"$(json_escape "$install_cmd")\"}" >> "$REPORT_TMP"
  log_err "$cmd missing and not installed"
  return 1
}

check_docker_compose() {
  local reason="$1"
  if docker compose version >/dev/null 2>&1; then
    echo "{\"name\":\"docker-compose-plugin\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
    log_info "docker compose plugin detected"
    return 0
  fi

  local pkg="docker-compose-plugin"
  local install_cmd
  install_cmd=$(install_package_cmd "$pkg")
  log_warn "docker compose plugin missing ($reason)"
  if [[ -n "$install_cmd" ]]; then
    log_info "Suggested install: $install_cmd"
  fi

  if run_install_cmd "$install_cmd" && docker compose version >/dev/null 2>&1; then
    echo "{\"name\":\"docker-compose-plugin\",\"status\":\"pass\",\"reason\":\"installed-by-script\"}" >> "$REPORT_TMP"
    log_info "docker compose plugin installed successfully"
    return 0
  fi

  echo "{\"name\":\"docker-compose-plugin\",\"status\":\"fail\",\"reason\":\"missing\",\"install\":\"$(json_escape "$install_cmd")\"}" >> "$REPORT_TMP"
  log_err "docker compose plugin missing and not installed"
  return 1
}

finalize_prereq_report() {
  local overall_status="$1"
  {
    echo "{"
    echo "  \"target\": \"$TARGET\"," 
    echo "  \"status\": \"$overall_status\"," 
    echo "  \"checks\": ["
    awk 'BEGIN{first=1} {if(first){printf "    %s",$0; first=0} else {printf ",\n    %s",$0}} END{printf "\n"}' "$REPORT_TMP"
    echo "  ]"
    echo "}"
  } > "$REPORT_FILE"
}
