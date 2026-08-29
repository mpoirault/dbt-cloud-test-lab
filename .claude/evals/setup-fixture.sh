#!/usr/bin/env bash
# Build a scratch fixture for the flow/commit evals: a bare "origin" plus a
# clone that carries this repo's agent tooling (.claude, AGENTS.md).
# A committed fixture cannot contain a .git dir, so this script builds one.
# Usage: setup-fixture.sh <target-dir>
set -euo pipefail

target=${1:?usage: setup-fixture.sh <target-dir>}
repo_root=$(git rev-parse --show-toplevel)

mkdir -p "$target"
target=$(cd "$target" && pwd)

git init --bare --quiet --initial-branch=main "$target/origin.git"
git clone --quiet "$target/origin.git" "$target/clone"

cp -r "$repo_root/.claude" "$target/clone/.claude"
rm -rf "$target/clone/.claude/evals" "$target/clone/.claude/settings.local.json"
cp "$repo_root/AGENTS.md" "$target/clone/AGENTS.md"
printf '@AGENTS.md\n' >"$target/clone/CLAUDE.md"
printf '# Fixture labb\n\nScratch repo for the flow/commit evals.\n' \
  >"$target/clone/README.md"

cat >"$target/clone/.pre-commit-config.yaml" <<'YAML'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
YAML

git -C "$target/clone" add -A
git -C "$target/clone" commit --quiet -m "seed eval fixture"
git -C "$target/clone" push --quiet -u origin main

if command -v pre-commit >/dev/null 2>&1; then
  (cd "$target/clone" && pre-commit install --install-hooks >/dev/null)
else
  echo "note: pre-commit not on PATH; evals 8-9 need it installed in the clone"
fi

echo "fixture ready: $target/clone (origin: $target/origin.git)"
echo "run each eval in a fresh session with cwd $target/clone"
