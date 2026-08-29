#!/usr/bin/env bash
# PreToolUse guardrail: no file mutations while on main.
# Denies Edit/Write always, and mutating Bash commands, when the current
# branch is main. Read-only commands pass. The flow skill is the happy
# path; this hook is the deterministic backstop when it does not fire.
set -euo pipefail

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ "$branch" = "main" ] || exit 0

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

reason="On main: create a work branch first (flow skill)."

case "$tool" in
  Edit|Write|NotebookEdit)
    deny "$reason"
    ;;
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    # mutations: git writes, file writes, redirects, in-place edits, apply
    if grep -qE '(^|[;&|]\s*)git (commit|push|merge|rebase|cherry-pick|revert|mv|rm)\b' <<<"$cmd" \
      || grep -qE '(^|[;&|]\s*)(rm|mv|cp|touch|mkdir|tee|truncate)\b' <<<"$cmd" \
      || grep -qE '(^|[;&|]\s*)sed .*-i' <<<"$cmd" \
      || grep -qE '>>?[^&]' <<<"$cmd" \
      || grep -qE 'terraform (apply|destroy|import|state)\b' <<<"$cmd"; then
      deny "$reason"
    fi
    exit 0
    ;;
esac

exit 0
