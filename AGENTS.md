# Agent instructions

Shared instructions for all coding agents in this repo. CLAUDE.md and GEMINI.md import this file. Put new rules here, not there.

## What this repo is

A personal lab that manages a dbt Cloud project and BigQuery with terraform. The dbt project lives in `dbt/`. The terraform config lives in `infrastructure/`. README.md holds the full setup and the design decisions. Read it before infra work.

## Environment and commands

- Binaries (terraform, uv, dbt Cloud CLI) are pinned in `mise.toml`.
- Run `source .venv/bin/activate` once, then call tools directly. Do not prefix commands with `uv run` or `python3 -c`.
- If the venv is missing, run `mise trust && mise run setup`.
- Run terraform from `infrastructure/` with `-var-file=env/lab/vars.tfvars`.

## Terraform workflow

- Apply is local and manual. Never apply from CI.
- CI runs a plan on each PR that touches `infrastructure/`. The job fails when the plan is not empty.
- Before you push an infra change, apply it locally from the branch. Green CI means the branch matches the deployed state.
- If a new variable or output holds a credential, mark it `sensitive`.

## Git workflow

- Never edit files on main. Work on a `type/kebab-slug` branch (feat/, fix/, chore/, refactor/, docs/, test/) created from the fresh `origin/main` tip. A guardrail hook blocks mutations on main.
- Branch rules and task routing live in the `flow` skill of the test-lab-learning plugin (enabled in `.claude/settings.json`). Commit and push rules live in the `commit` skill when it is installed, else in the flow fallback. Follow them for every commit: one meaningful change per commit, no attribution trailers, never `--no-verify`.
- Push on request, then stop. PRs are created only through a PR skill (typed /pr), never by the agent on its own.

## Checks

- Pre-commit hooks run on every commit (fmt, validate, checkov, ruff, yamlfix).
- To check before a commit, run `pre-commit run --all-files`.
- Do not mark work done before the relevant check passes.

## Safety

- Never run `terraform destroy`. Hand the command to the user instead.
- Never delete files, branches, or cloud resources without explicit approval.
- Never commit or push unless the user asks.
