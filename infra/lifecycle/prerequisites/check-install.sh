#!/usr/bin/env bash
# Purpose:
#   Unified prerequisite checker/installer for dev, onprem, and gcp targets.
# Inputs:
#   --target {dev|onprem|gcp}
#   --mode {interactive|check-only} (default: interactive)
# Outputs:
#   - Human-readable PASS/FAIL report to stdout
#   - JSON report at /tmp/oal-prereq-report.json
# Preconditions:
#   - bash available
# Failure modes:
#   - exits 1 when any required dependency remains missing.
# Examples:
#   - bash infra/lifecycle/prerequisites/check-install.sh --target dev
#   - bash infra/lifecycle/prerequisites/check-install.sh --target gcp --mode check-only
# Security notes:
#   - Uses sudo for package installation when required; never handles application secrets.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET=""
CHECK_INSTALL_MODE="interactive"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --mode)
      CHECK_INSTALL_MODE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 --target {dev|onprem|gcp} [--mode {interactive|check-only}]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exit 2
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Missing required argument: --target"
  exit 2
fi

if [[ "$TARGET" != "dev" && "$TARGET" != "onprem" && "$TARGET" != "gcp" ]]; then
  echo "Invalid --target value: $TARGET"
  exit 2
fi

if [[ "$CHECK_INSTALL_MODE" != "interactive" && "$CHECK_INSTALL_MODE" != "check-only" ]]; then
  echo "Invalid --mode value: $CHECK_INSTALL_MODE"
  exit 2
fi

REPORT_TMP="$(mktemp)"
export REPORT_TMP TARGET CHECK_INSTALL_MODE

# shellcheck source=/dev/null
source "$SCRIPT_DIR/checks/common.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/checks/dev.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/checks/onprem.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/checks/gcp.sh"

failed=0

check_or_install_cmd "bash" "bash" "required shell runtime" || failed=1
check_or_install_cmd "git" "git" "required for source and version metadata" || failed=1
check_or_install_cmd "curl" "curl" "required for HTTP checks and installers" || failed=1
check_or_install_cmd "docker" "docker.io" "required for container build and run" || failed=1
check_docker_compose "required for compose-based workflows" || failed=1
check_or_install_cmd "jq" "jq" "required for JSON processing in lifecycle scripts" || failed=1

case "$TARGET" in
  dev) check_dev_dependencies || failed=1 ;;
  onprem) check_onprem_dependencies || failed=1 ;;
  gcp) check_gcp_dependencies || failed=1 ;;
esac

if [[ "$failed" -eq 0 ]]; then
  finalize_prereq_report "pass"
  echo "Prerequisite validation passed for target '$TARGET'."
  exit 0
fi

finalize_prereq_report "fail"
echo "Prerequisite validation failed for target '$TARGET'. See /tmp/oal-prereq-report.json"
exit 1
