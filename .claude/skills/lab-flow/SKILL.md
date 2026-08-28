---
name: lab-flow
description: Branch and commit workflow for this repo. Use BEFORE the first
  file edit of any task (create a work branch first, never edit on main),
  and whenever committing or pushing. Covers branch naming, commit style,
  pre-commit handling, and the end-of-task confirmation.
---

# lab-flow: branch and commit workflow

Main is protected. All work happens on a branch and reaches main through a
PR that Max opens himself.

## Branching

Do this before the first file edit of a task:

1. If the current branch is main, or the task is unrelated to the current
   branch's topic, create a new branch. If the task continues the current
   branch's topic, stay on it and skip the rest of this section.
2. If uncommitted changes block the switch, ask Max: commit them first, or
   bring them along.
3. Update main before you branch: `git fetch origin`.
4. Create the branch from the fresh remote tip:
   `git checkout -b <type>/<slug> origin/main`.

Branch names are `type/kebab-slug`. Pick the type from: feat, fix, chore,
refactor, docs, test. Keep the slug to 2-4 words that name the task
(example: `feat/lab-flow-skill`). If Max names the branch, use his name.

## Committing

Commit only when Max says yes (see End of task). Then:

1. Gather context in one message: `git status`, `git diff HEAD`,
   `git log --oneline -5`.
2. Group the changes. One commit holds one meaningful change. Edits that
   only make sense together are one change. Unrelated edits get separate
   commits with separate `git add` calls.
3. Write the message with the `writing` skill rules: imperative subject
   under 65 characters, active voice, no filler. Add a body only when the
   why is not visible in the diff.
4. Never add Co-Authored-By or any other attribution trailer.

## Pre-commit

Hooks run on every commit. If a hook modifies files, run `git add` on the
fixed files and commit again once. If a hook fails, fix the cause and
retry. Never use `--no-verify`.

## End of task

At a natural stopping point, propose in one message: the commit split with
each message, and the push. When Max says yes, commit and push. Then stop.
Max opens the PR himself. Never run `gh pr create` in this repo.
