#!/usr/bin/env bash
# Regenerate the skills table in README.md from manifest.json.
# Replaces the content between `<!-- BEGIN SKILLS -->` and
# `<!-- END SKILLS -->` markers. Idempotent.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

table=$(mktemp)
trap 'rm -f "$table"' EXIT

{
  echo "| Skill | Kind | Source |"
  echo "|-------|------|--------|"
  jq -r '
    .skills
    | to_entries
    | sort_by(.key)
    | .[]
    | .key as $name
    | .value.source as $src
    | if $src.kind == "fork" then
        $src.repo as $repo
        | (if ($repo | test("://|@")) then $repo else "https://github.com/" + $repo end) as $url
        | "| `\($name)` | \($src.kind) | [`\($repo)`](\($url)) |"
      else
        "| `\($name)` | \($src.kind) |  |"
      end
  ' manifest.json
} > "$table"

new_readme=$(mktemp)
awk -v table_file="$table" '
  /<!-- BEGIN SKILLS -->/ {
    print
    print ""
    while ((getline line < table_file) > 0) print line
    close(table_file)
    print ""
    in_block = 1
    next
  }
  /<!-- END SKILLS -->/ { in_block = 0; print; next }
  !in_block { print }
' README.md > "$new_readme"

if ! cmp -s README.md "$new_readme"; then
  mv "$new_readme" README.md
  echo "README.md skills table regenerated."
else
  rm "$new_readme"
fi
