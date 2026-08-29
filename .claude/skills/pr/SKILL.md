---
name: pr
description: Draft and create a pull request for the current branch. The user
  triggers this with /pr. Typed /pr is the consent to create the PR after the
  draft is shown.
disable-model-invocation: true
---

# pr

A typed /pr is the user's consent to create a PR. Nothing else is. Never
create a PR outside this skill.

## Behavior

1. Run `git fetch origin`, `git log origin/main..HEAD`, and
   `git diff origin/main...HEAD --stat`.
2. If the branch has unpushed commits or no upstream, follow the `commit`
   skill first.
3. Draft the PR:
   - Title: imperative, 65 characters max, like a commit subject.
   - Body: what changed and why, in a few sentences. Add a short list only
     when the branch holds several distinct changes. No checklists, no
     screenshots section, no boilerplate.
   - If the host machine has a writing-style skill (for example `writing`
     or `simple-english`), apply it to the wording. If none exists, the
     rules above are enough.
4. Show the draft title and body, then end the turn. Run no command in
   the same turn as the draft.
5. Wait for the user's yes. It arrives as a separate message.
6. On yes: run `gh pr create --title <title> --body <body>`, report the PR
   URL, and stop. Never merge the PR.
