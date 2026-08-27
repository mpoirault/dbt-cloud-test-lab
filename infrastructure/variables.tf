variable "gcp_project" {
  description = "GCP project id where BigQuery and other Google resources live."
  type        = string
}

variable "gcp_region" {
  description = "GCP region for regional resources (BigQuery datasets, etc)."
  type        = string
}

variable "state_bucket" {
  description = "Name of the GCS bucket holding the terraform state. Created once by hand (see README setup); must match the bucket in env/<env>/backend-config.tfvars, since backend blocks cannot read variables."
  type        = string
}

variable "gh_owner" {
  description = "GitHub org or user that owns the repos managed by this stack."
  type        = string
}

variable "gh_repo_name" {
  description = "Name of the GitHub repository (feeds the dbt Cloud remote_url and the repo dataset label)."
  type        = string
}

variable "gh_installation_id" {
  description = "Numeric installation ID of the dbt Cloud GitHub App on the GitHub account/org that owns the repo. Required for the github_app clone strategy. Find it via the GitHub install-settings URL (.../settings/installations/<id>) or the dbt Cloud API. Not Terraform-managed."
  type        = number
}

variable "dbt_project_name" {
  description = "Name of the dbt Cloud project to create. This should be unique across your dbt Cloud account, as dbt Cloud does not allow duplicate project names."
  type        = string
}

variable "dbt_project_subdirectory" {
  description = "Path within the repo where the dbt project lives, so dbt Cloud parses only the dbt code (not terraform/ or other root files)."
  type        = string
  default     = "dbt"
}

variable "dbt_account_id" {
  description = "Numeric dbt Cloud account id (not the account name). Easiest way to find it: its in the URL when you're logged in to dbt Cloud."
  type        = number
}

variable "dbt_token" {
  description = "API token (service token or PAT) for authenticating with dbt Cloud."
  type        = string
  sensitive   = true
}

variable "dbt_host_url" {
  description = "Base URL for the dbt Cloud API. Defaults to the US multi-tenant instance; override for a different cell or a private deployment (e.g., https://<cell>.dbt.com/api)."
  type        = string
  default     = "https://cloud.getdbt.com/api"
}
