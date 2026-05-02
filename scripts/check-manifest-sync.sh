#!/usr/bin/env bash
# Verify that every directory under skills/ has a matching entry in
# manifest.json, and every entry in manifest.json has a directory.
# Exits non-zero with a list of mismatches if anything is out of sync.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ ! -f manifest.json ]]; then
  echo "manifest.json not found at $repo_root" >&2
  exit 1
fi

manifest_keys=$(jq -r '.skills | keys[]' manifest.json | sort)
fs_dirs=$(find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort || true)

missing_in_manifest=$(comm -23 <(echo "$fs_dirs") <(echo "$manifest_keys") | sed '/^$/d')
missing_in_fs=$(comm -13 <(echo "$fs_dirs") <(echo "$manifest_keys") | sed '/^$/d')

failed=0
if [[ -n "$missing_in_manifest" ]]; then
  echo "Skills present on disk but missing from manifest.json:"
  echo "$missing_in_manifest" | sed 's/^/  /'
  failed=1
fi
if [[ -n "$missing_in_fs" ]]; then
  echo "Entries in manifest.json with no skills/<name>/ directory:"
  echo "$missing_in_fs" | sed 's/^/  /'
  failed=1
fi

if [[ $failed -eq 0 ]]; then
  echo "manifest.json and skills/ are in sync."
fi
exit $failed
