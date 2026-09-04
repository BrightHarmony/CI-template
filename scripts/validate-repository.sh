#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

required_files=(
  .github/workflows/ci-node.yml
  .github/workflows/ci-python.yml
  .github/workflows/security.yml
  .github/workflows/build-container.yml
  .github/workflows/publish-container.yml
  .github/workflows/release-container.yml
  .github/workflows/self-test.yml
  .github/CODEOWNERS
  .github/dependabot.yml
  config/rulesets/business-main.json
  config/rulesets/research-main.json
  config/rulesets/release-tags.json
  config/rulesets/template-main.json
  README.md
  docs/rulesets.md
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required file: $file" >&2
    exit 1
  fi
done

yaml_files=()
while IFS= read -r file; do
  yaml_files+=("$file")
done < <(find .github/workflows .github -maxdepth 2 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort -u)

ruby -e '
  require "yaml"
  ARGV.each do |file|
    YAML.safe_load(File.read(file), aliases: true)
  rescue StandardError => error
    warn "#{file}: #{error.message}"
    exit 1
  end
' "${yaml_files[@]}"

ruby -e '
  require "json"
  ARGV.each do |file|
    JSON.parse(File.read(file))
  rescue StandardError => error
    warn "#{file}: #{error.message}"
    exit 1
  end
' config/rulesets/*.json

invalid_refs=0
while IFS= read -r match; do
  reference="${match##*@}"
  reference="${reference%%[[:space:]#]*}"
  if [[ ! "$reference" =~ ^[0-9a-f]{40}$ ]]; then
    echo "External Action is not pinned to a full commit SHA: $match" >&2
    invalid_refs=1
  fi
done < <(grep -RhoE 'uses:[[:space:]]+[^[:space:]#]+@[^[:space:]#]+' .github/workflows || true)

if [[ "$invalid_refs" -ne 0 ]]; then
  exit 1
fi

for workflow in .github/workflows/*.yml; do
  if ! grep -q '^permissions:' "$workflow"; then
    echo "Workflow must declare top-level permissions: $workflow" >&2
    exit 1
  fi
done

bash -n scripts/validate-repository.sh

if grep -q '@YOUR_ORG/platform-team' .github/CODEOWNERS; then
  echo "WARNING: replace the CODEOWNERS placeholder before enabling required reviews." >&2
fi

echo "Repository structure, YAML syntax, permissions, and Action pins are valid."
