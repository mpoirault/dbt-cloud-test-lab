---
name: commit
description: Commit and push procedure for this repo. Use whenever committing
  or pushing. Covers change grouping, commit message style, pre-commit
  handling, and the end-of-task confirmation.
---

# commit

One commit holds one meaningful change, and nothing is committed or pushed
without the user's yes. This skill defines the commit and push procedure.

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
4. Do not create a PR. PR creation belongs to the `pr` skill, which the
   user triggers with /pr.

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
commit:  route stg_orders through the payments seed

         The orders staging model joined raw payments directly, which
         broke when the source schema moved. The seed is stable.
```
