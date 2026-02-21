#!/usr/bin/env bash
# Purpose: Validate documentation location, structure, and relative links.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

cd "$ROOT_DIR"

echo "[docs-validate] Checking markdown location policy..."
DISALLOWED_MD="$(git ls-files '*.md' | grep -vE '^(README\.md|AGENTS\.md|docs/)' || true)"
if [[ -n "${DISALLOWED_MD}" ]]; then
  echo "Found markdown files outside allowed paths:"
  echo "${DISALLOWED_MD}"
  exit 1
fi

echo "[docs-validate] Checking required sections in docs pages..."
while IFS= read -r doc_file; do
  if ! grep -q '^# ' "$doc_file"; then
    echo "Missing top-level title in $doc_file"
    exit 1
  fi
  for section in '## Purpose' '## Scope' '## Related'; do
    if ! grep -q "^${section}$" "$doc_file"; then
      echo "Missing required section '${section}' in $doc_file"
      exit 1
    fi
  done
done < <(find docs -type f -name '*.md' | sort)

echo "[docs-validate] Checking relative links in README.md and docs..."
for md_file in README.md $(find docs -type f -name '*.md' | sort); do
  md_dir="$(dirname "$md_file")"
  while IFS= read -r link; do
    clean_link="${link%%#*}"
    clean_link="${clean_link%%\?*}"

    if [[ -z "$clean_link" ]]; then
      continue
    fi

    if [[ "$clean_link" =~ ^(https?://|mailto:) ]]; then
      continue
    fi

    if [[ "$clean_link" == /* ]]; then
      link_path="${clean_link#/}"
    else
      link_path="$md_dir/$clean_link"
    fi

    if [[ ! -e "$link_path" ]]; then
      echo "Broken relative link in $md_file -> $link"
      exit 1
    fi
  done < <(grep -oE '\[[^][]+\]\(([^)]+)\)' "$md_file" | sed -E 's/.*\(([^)]+)\)$/\1/' | grep -v '^#' || true)
done

echo "[docs-validate] Documentation validation passed."
