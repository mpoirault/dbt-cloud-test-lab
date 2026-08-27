resource "dbtcloud_project" "this" {
  name = var.dbt_project_name
  # dbt code sits in dbt/ so dbt Cloud never sees the terraform files
  dbt_project_subdirectory = var.dbt_project_subdirectory
}

# account level BigQuery connection, reusable across projects.
# the provider has no write-only field for the key so the private key ends up
# in tf state. fine here, it's already in state via the key resource anyway
# and the state bucket is private. getting rid of it entirely means WIF, later.
resource "dbtcloud_global_connection" "bigquery" {
  name = "BigQuery - ${var.gcp_project}"

  bigquery = {
    gcp_project_id  = var.gcp_project
    location        = var.gcp_region
    timeout_seconds = 300

    private_key_id              = local.sa_key_json.private_key_id
    private_key                 = local.sa_key_json.private_key
    client_email                = local.sa_key_json.client_email
    client_id                   = local.sa_key_json.client_id
    auth_uri                    = local.sa_key_json.auth_uri
    token_uri                   = local.sa_key_json.token_uri
    auth_provider_x509_cert_url = local.sa_key_json.auth_provider_x509_cert_url
    client_x509_cert_url        = local.sa_key_json.client_x509_cert_url
  }
}

resource "dbtcloud_repository" "this" {
  project_id             = dbtcloud_project.this.id
  remote_url             = "git@github.com:${var.gh_owner}/${var.gh_repo_name}.git"
  github_installation_id = var.gh_installation_id
  git_clone_strategy     = "github_app"
}

resource "dbtcloud_project_repository" "this" {
  project_id    = dbtcloud_project.this.id
  repository_id = dbtcloud_repository.this.repository_id
}

resource "dbtcloud_environment" "dev" {
  project_id    = dbtcloud_project.this.id
  name          = "dev"
  dbt_version   = "latest"
  type          = "development"
  connection_id = dbtcloud_global_connection.bigquery.id
  # dev environments dont take a credential_id
}

# --- CI ---
# one fixed CI dataset instead of per-PR schemas. it's just me on this repo
# and ci.yml cancels superseded runs per PR anyway. if that ever changes the
# trigger API has schema_override.
resource "dbtcloud_bigquery_credential" "ci" {
  project_id  = dbtcloud_project.this.id
  dataset     = "dbt_ci" # generate_schema_name -> dbt_ci_cloud_<stage>; raw stays shared cloud_raw
  num_threads = 4
  # no connection_id on purpose: with it the provider creates an "adapter"
  # type credential wich our old bigquery_v0 connection rejects at profile
  # generation ("Failed to generate profile due to incorrect credentials").
  # without it you get the plain "bigquery" type and everything works.
}

resource "dbtcloud_environment" "ci" {
  project_id    = dbtcloud_project.this.id
  name          = "ci"
  dbt_version   = "latest"
  type          = "deployment"
  connection_id = dbtcloud_global_connection.bigquery.id
  credential_id = dbtcloud_bigquery_credential.ci.credential_id
  # no deployment_type here, "production" is taken by the prod env
}

# native dbt Cloud CI. github_webhook is "Run on pull requests" in the UI,
# the github app picks up PR events, builds the branch and posts its own
# check on the PR. no seeding in CI, thats the prod jobs job. CI reads the
# shared cloud_raw dataset that is already seeded.
resource "dbtcloud_job" "ci_build" {
  project_id     = dbtcloud_project.this.id
  environment_id = dbtcloud_environment.ci.environment_id
  name           = "ci-build-pr"
  job_type       = "ci"
  target_name    = "ci"
  num_threads    = 4

  # slim CI: only build what the PR touched plus downstream, the rest is
  # deferred to the prod manifest. needs at least one succesful prod run
  # first, for the very first one trigger prod-build-merge in the UI.
  # edge case: a PR that only changes a seed csv ends up as a near empty run
  # (state:modified+ selects the seed, the --exclude drops it again). fine,
  # seeds go out with CD on merge.
  deferring_environment_id = dbtcloud_environment.prod.environment_id

  execute_steps = [
    "dbt build -s state:modified+ --defer --favor-state --exclude resource_type:seed",
  ]

  triggers = {
    github_webhook       = true
    git_provider_webhook = false
    schedule             = false
    on_merge             = false
  }
  triggers_on_draft_pr = false

  generate_docs        = false
  run_generate_sources = false # freshness only warns anyway (static seed timestamps), keep it out of CI

  execution = {
    timeout_seconds = 900
  }
}

# --- prod + CD ---
# the dataset here is just the fallback. every model/seed/snapshot sets an
# explicit +schema so the macro never actually falls back to it in prod.
resource "dbtcloud_bigquery_credential" "prod" {
  project_id  = dbtcloud_project.this.id
  dataset     = "dbt_prod"
  num_threads = 4
  # no connection_id, same story as the ci credential above
}

resource "dbtcloud_environment" "prod" {
  project_id      = dbtcloud_project.this.id
  name            = "prod"
  dbt_version     = "latest"
  type            = "deployment"
  deployment_type = "production"
  connection_id   = dbtcloud_global_connection.bigquery.id
  credential_id   = dbtcloud_bigquery_credential.prod.credential_id
}

# the CD job: merging to main deploys prod. no schedule, this lab doesnt run
# anything on cron. seeds only run here and as their own step, source() has
# no dag edge to seeds so folding them into the build races the reload.
# freshness goes through run_generate_sources so it can warn without failing
# the run (seed timestamps are static, it always warns).
resource "dbtcloud_job" "prod_build" {
  project_id     = dbtcloud_project.this.id
  environment_id = dbtcloud_environment.prod.environment_id
  name           = "prod-build-merge"
  job_type       = "merge"
  target_name    = "prod" # the schema macro keys on this, dont change it
  num_threads    = 4

  execute_steps = [
    "dbt seed",
    "dbt build --exclude resource_type:seed",
  ]

  triggers = {
    github_webhook       = false
    git_provider_webhook = false
    schedule             = false
    on_merge             = true
  }

  generate_docs        = true
  run_generate_sources = true

  execution = {
    timeout_seconds = 1800
  }
}
