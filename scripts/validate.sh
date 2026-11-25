#!/usr/bin/env bash
# Validates the marketplace, every plugin, and every skill's frontmatter.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
err() { echo "ERROR: $*" >&2; fail=1; }

command -v jq >/dev/null || { echo "jq is required" >&2; exit 2; }

jq empty .claude-plugin/marketplace.json || err "marketplace.json is not valid JSON"

# Every marketplace entry points at a plugin dir whose plugin.json name matches.
while IFS=$'\t' read -r name source; do
  manifest="$source/.claude-plugin/plugin.json"
  [[ -f "$manifest" ]] || { err "$name: missing $manifest"; continue; }
  jq empty "$manifest" || { err "$manifest is not valid JSON"; continue; }
  [[ "$(jq -r .name "$manifest")" == "$name" ]] || err "$manifest name does not match marketplace entry '$name'"
done < <(jq -r '.plugins[] | [.name, .source] | @tsv' .claude-plugin/marketplace.json)

# Every plugin dir is listed in the marketplace.
for dir in plugins/*/; do
  name="$(basename "$dir")"
  jq -e --arg n "$name" '.plugins[] | select(.name == $n)' .claude-plugin/marketplace.json >/dev/null \
    || err "plugins/$name is not listed in marketplace.json"
done

# Every skill has frontmatter with a name matching its folder and a description.
for skill in plugins/*/skills/*/SKILL.md; do
  folder="$(basename "$(dirname "$skill")")"
  [[ "$(head -1 "$skill")" == "---" ]] || { err "$skill: missing frontmatter"; continue; }
  front="$(awk 'NR>1 && /^---$/ {exit} NR>1 {print}' "$skill")"
  name="$(sed -n 's/^name:[[:space:]]*//p' <<<"$front")"
  desc="$(sed -n 's/^description:[[:space:]]*//p' <<<"$front")"
  [[ "$name" == "$folder" ]] || err "$skill: name '$name' does not match folder '$folder'"
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || err "$skill: name '$name' is not kebab-case"
  [[ -n "$desc" ]] || err "$skill: missing description"
done

# Defer to the official validator when the CLI is available.
if command -v claude >/dev/null; then
  claude plugin validate . || err "claude plugin validate failed"
fi

if (( fail )); then echo "Validation failed." >&2; exit 1; fi
echo "All plugins and skills valid."
