---
name: flow
description: Task router and branching workflow for this repo. Use BEFORE the
  first file edit of any task (create a work branch first, never edit on
  main). Owns branch creation and naming, and routes commit, push, and
  end-of-task work to the right skill.
---

# flow

Main is protected. Every change reaches main through a PR. This skill owns
the branch procedure and the routing map, nothing else. The rules for each
routed step live in the skill that owns it. Do not restate them here.

## Behavior: start a task

Follow this before the first file edit of any task.

1. Run `git branch --show-current`.
2. If the branch is not main and the task continues that branch's topic,
   stay on it and stop here.
3. If uncommitted changes block a branch switch, ask the user: commit them
   first, or bring them along. Wait for the answer.
4. Run `git fetch origin`.
5. Run `git checkout -b <type>/<slug> origin/main` with a name in the
   branch format below.
6. If the user gave a branch name, use that name instead.

## Routing map

- If the user asks to commit or push, follow the `commit` skill.
- If the task reaches a natural stopping point, follow the `commit` skill
  for the end-of-task confirmation.

## Branch format

```text
<type>/<kebab-slug>
```

The slug is 2-4 kebab-case words that name the task.

Types:

- feat: new capability
- fix: bug fix
- chore: maintenance, tooling, config
- refactor: restructure without behavior change
- docs: documentation only
- test: tests only

## Example

```text
task:    "add a freshness test to the orders source"
branch:  test/orders-source-freshness
```
