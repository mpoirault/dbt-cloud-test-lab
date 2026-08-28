---
name: lab-flow
description: Branch and commit workflow for this repo. Use BEFORE the first
  file edit of any task (create a work branch first, never edit on main),
  and whenever committing or pushing. Covers branch naming, commit style,
  pre-commit handling, and the end-of-task confirmation.
---

# lab-flow

Main is protected. Every change reaches main through a PR, and the user
opens that PR. This skill defines the branch, commit, and push procedure.

## Usage

Follow "Behavior: start a task" before the first file edit of any task.
Follow "Behavior: commit" for every commit. Follow "Behavior: end a task"
when the work is done.

## Behavior: start a task

1. Run `git branch --show-current`.
2. If the branch is not main and the task continues that branch's topic,
   stay on it and stop here.
3. If uncommitted changes block a branch switch, ask the user: commit them
   first, or bring them along. Wait for the answer.
4. Run `git fetch origin`.
5. Run `git checkout -b <type>/<slug> origin/main` with a name in the
   branch format below.
6. If the user gave a branch name, use that name instead.

## Behavior: commit

Commit only when the user approved it (see "Behavior: end a task") or
asked for it directly.

1. Run `git status`, `git diff HEAD`, and `git log --oneline -5`.
2. Group the changes. One commit holds one meaningful change. Edits that
   only make sense together are one change. Unrelated edits get separate
   commits.
3. Stage one group at a time with explicit paths: `git add <paths>`.
4. Commit with a message in the commit format below.
5. If a pre-commit hook modified files, run `git add` on the fixed files
   and commit again once.
6. If a pre-commit hook failed, fix the cause and retry. Never use
   `--no-verify`.

## Behavior: end a task

1. At a natural stopping point, propose in one message: the commit split,
   each commit message, and the push.
2. Wait for the user's yes.
3. On yes: commit per the procedure above, then `git push -u origin
   <branch>`, then stop.
4. Never run `gh pr create`. The user opens the PR.

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

## Commit format

```text
<imperative subject, 65 characters max>

<optional body: the why, only when it is not visible in the diff>
```

Rules:

- Imperative mood, active voice, no filler words.
- If the host machine has a writing-style skill (for example `writing` or
  `simple-english`), apply it to the wording. If none exists, the rules
  above are enough.
- Never add Co-Authored-By or any other attribution trailer.

## Example

```text
branch:  feat/lab-flow-skill
commit:  add lab-flow skill and branch guardrail hook

         Work in this repo now starts on a type/slug branch, never on
         main. A PreToolUse hook denies mutations on main as backstop.
```
