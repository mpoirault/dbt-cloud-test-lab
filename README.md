# dbt-cloud-test-lab

This is my personal lab for playing around with dbt cloud.

## What's here

- `infrastructure/`: everything terraform manages. The BigQuery datasets, the runner SA and the read-only plan SA, and the dbt Cloud side: project, BigQuery connection, dev/ci/prod environments, the CI and merge jobs, and the repo link through the GitHub App
- `dbt/`: the dbt project, built on the jaffle-shop seeds. Seeds sit behind `source()` with freshness checks, an SCD2 snapshot feeds staging, then intermediate and marts. Groups, tags and meta follow [`docs/governance.md`](docs/governance.md), and `dbt-bouncer.yml` enforces the modeling standards. Might add Mesh later, that was the original plan and its why the governance.md is here.
- CI: native dbt Cloud CI builds each PR into a temporary schema and posts its check, `ci_dbt` lints and runs bouncer on dbt changes, `ci_terraform` runs a plan on infrastructure changes and fails when it is not empty (the plan body never reaches the public log)
- CD: merging to main runs `prod-build-merge`, seeds first, then the build.

## AI-assisted workflow

This repo doubles as a demo and testing ground for an AI-assisted development workflow. Coding agents (Claude Code, Gemini CLI) get their instructions from [`AGENTS.md`](AGENTS.md), which `CLAUDE.md` and `GEMINI.md` import. The repo carries its own agent tooling in `.claude/`: the `lab-flow` skill holds the branch and commit rules (work starts on a `type/slug` branch, one meaningful change per commit, no attribution trailers), and a guardrail hook denies any file mutation while on main. Expect this setup to change, trying things out is the point.

## Decisions

- Git auth is the native GitHub App, not a deploy key. This allows for native dbt Cloud job triggers.
- dbt code lives in the `dbt/` subdir
- One runner SA with project level roles.
- Toolchain split: binaries are pinned in `mise.toml` (dbt Cloud CLI, terraform, uv), Python dev tools in `pyproject.toml` + `uv.lock`. Pre-commit hooks call tools through `uv run` so hooks, editor and CI resolve the same versions.
- The dbt Cloud CLI is the native Go binary (mise ubi backend), not the PyPI `dbt` wrapper, wich forces a classic pip venv
- Datasets: raw is shared (`cloud_raw` in every target, seeds load once). Dev models build to `<dev dataset>_cloud_<stage>`, prod to `cloud_<stage>`. The routing sits in one macro, `dbt/macros/generate_schema_name.sql`
- CD is the merge job `prod-build-merge`, no cron, no alerting webhooks, no drift automation. A manual `terraform plan` is the drift check
- `terraform plan` runs in `ci_terraform` under a dedicated read-only SA (`terraform-plan-ci`, granular read roles plus bucket scoped write for backend locking). If there is drift, the pipeline fails.
- dbt-bouncer runs on every local commit and again in `ci_dbt` on PRs that touch `dbt/` (manifest checks only), wich comments failures on the PR

## Infrastructure layout

`infrastructure/` follows the usual terraform repo shape: a flat root with topic files, a `modules/` map, and an `env/` folder.

```text
infrastructure/
├── providers.tf          # terraform block, empty gcs backend, provider configs
├── locals.tf
├── variables.tf
├── bigquery.tf           # calls modules/bigquery_dataset per dataset
├── dbt_cloud.tf          # project, connection, environments, jobs
├── iam.tf                # runner SA + the read-only plan SA for CI
├── modules/
│   └── bigquery_dataset/
└── env/
    └── lab/              # backend-config.tfvars + vars.tfvars(.example)
```

There is only one env (`lab`), a real env split is too much for a demo. The folder exists anyway because thats where productionalisation starts: dev/preprod/prod each get their own backend-config and vars file there, state split per terraform workspace. The backend block is empty on purpose, the bucket and prefix come from `env/lab/backend-config.tfvars` at init time.

## Setup

One prerequisite: [mise](https://mise.jdx.dev/getting-started.html) (`curl https://mise.run | sh`, then add `eval "$(~/.local/bin/mise activate bash)"` to your shell rc). Everything else is pinned in the repo:

```bash
mise trust && mise run setup

# infra
cd infrastructure
cp env/lab/vars.tfvars.example env/lab/vars.tfvars   # fill in, gitignored
gcloud auth application-default login

# one-time: create the state bucket. terraform cannot manage its own backend
gcloud storage buckets create gs://<your-tfstate-bucket> \
  --location=<region> --uniform-bucket-level-access --public-access-prevention
gcloud storage buckets update gs://<your-tfstate-bucket> --versioning

terraform init -backend-config=env/lab/backend-config.tfvars
terraform plan -var-file=env/lab/vars.tfvars
terraform apply -var-file=env/lab/vars.tfvars
```

### CI configuration (once, after the first apply)

The `ci_terraform` workflow needs the non-secret tfvars mirrored as GitHub repo variables plus two secrets (values are never committed):

```bash
# variables, same values as env/lab/vars.tfvars
gh variable set GCP_PROJECT        # gcp_project
gh variable set GCP_REGION         # gcp_region
gh variable set STATE_BUCKET       # state_bucket (also the bucket in backend-config.tfvars)
gh variable set GH_OWNER           # gh_owner
gh variable set GH_REPO_NAME       # gh_repo_name
gh variable set GH_INSTALLATION_ID # gh_installation_id
gh variable set DBT_PROJECT_NAME   # dbt_project_name
gh variable set DBT_PROJECT_ID     # dbt Cloud project id (non-secret, same literal as dbt_project.yml)
gh variable set DBT_ACCOUNT_ID     # dbt_account_id
gh variable set DBT_HOST           # account host, e.g. <cell>.us1.dbt.com (no https://, no /api)

# secrets, prompted on stdin so nothing lands in shell history
gh secret set DBT_TOKEN            # same as dbt_token in vars.tfvars (a personal PAT, see Decisions)
gh secret set GCP_CI_SA_KEY        # key for terraform-plan-ci, created with:
# gcloud iam service-accounts keys create key.json \
#   --iam-account=terraform-plan-ci@<gcp_project>.iam.gserviceaccount.com
# (paste key.json contents into the secret, then delete the file)
```

### dbt Cloud CLI (local VSCode to dbt Cloud)

This repo uses the dbt Cloud CLI, not dbt Core. It runs your code on dbt Clouds infra, so no warehouse credentials live on your machine. mise installs it as the native Go binary from [GitHub releases](https://github.com/dbt-labs/dbt-cli/releases) and only puts it on PATH inside this directory, so `dbt` here never clashes with dbt Core in other repos. Dont install the PyPI `dbt` package: its a wrapper around the same binary with a legacy build step that breaks under uv.

```bash
dbt --version                               # -> dbt Cloud CLI (via mise)
```

VS Code: the [dbt Power User](https://marketplace.visualstudio.com/items?itemName=innoverio.vscode-dbt-power-user) extension (dbt Cloud mode) adds compiled-SQL preview, lineage, autocomplete and running models from the editor. Hooking it up is admittedly a bit hacky: the extension cant see mise-managed tools, but it does look for a `dbt` executable next to the selected Python interpreter. So `mise run setup` drops a tiny wrapper at `.venv/bin/dbt` (via `scripts/install-vscode-dbt-wrapper.sh`) that execs whatever dbt this repo pins, and the committed `.vscode/settings.json` points the interpreter at `.venv`. The extension then runs the exact same dbt version as your terminal. Re-run `mise run setup` if you ever recreate `.venv`. The extension also wants the Altimate AI API key + instance name in its settings (per user, never committed), dbt Cloud mode doesnt work without it.

Connect to your project (per user): download `dbt_cloud.yml` from dbt Cloud (profile, then dbt Cloud CLI), save it to `~/.dbt/dbt_cloud.yml` (it carries your token, never commit it). Then from `dbt/` run `dbt environment show` to confirm it resolves your project. The project link itself (`dbt-cloud: project-id`) is already committed in `dbt/dbt_project.yml`.

Dev credentials (per user): set in the UI at `https://<account-host>/settings/profile/credentials`, pick the project, set your BigQuery dataset to `dbt_<yourname>` (it auto-creates on first run), threads `4`. Use your accounts cell host, not the default `cloud.getdbt.com`. The dataset name matters: `generate_schema_name.sql` prefixes your models with it (you build to `dbt_<yourname>_cloud_<stage>`), while shared raw stays in `cloud_raw` for everyone.
