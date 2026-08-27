resource "google_service_account" "dbt_cloud_runner" {
  account_id   = "dbt-cloud-runner"
  display_name = "dbt Cloud runner"
  description  = "Service account used by dbt Cloud to read/write BigQuery in this project."
  project      = var.gcp_project
}

locals {
  dbt_cloud_runner_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
  ]
}

resource "google_project_iam_member" "dbt_cloud_runner" {
  for_each = toset(local.dbt_cloud_runner_roles)
  project  = var.gcp_project
  role     = each.value
  member   = "serviceAccount:${google_service_account.dbt_cloud_runner.email}"
}

# long lived SA key, the private key ends up in terraform state. ok for this
# lab, the state bucket is private, versioned and has public access prevention
# turned on.
resource "google_service_account_key" "dbt_cloud_runner" {
  service_account_id = google_service_account.dbt_cloud_runner.name
}

# --- plan-only identity for PR CI ---
# its key is created by hand with gcloud and pasted into the GCP_CI_SA_KEY
# github secret. on purpose no google_service_account_key resource here, that
# keeps the key out of tf state (the runner key above has to be in state
# because it flows to dbt Cloud, this one doesnt).
resource "google_service_account" "terraform_plan_ci" {
  account_id   = "terraform-plan-ci"
  display_name = "Terraform plan (PR CI)"
  description  = "Read-only identity for terraform plan in GitHub Actions PR CI. No apply permissions."
  project      = var.gcp_project
}

# granular read roles instead of basic ones like roles/viewer (checkov
# CKV_GCP_117). covers what plan actually refreshes: dataset metadata,
# service accounts and IAM policies.
locals {
  terraform_plan_ci_roles = [
    "roles/bigquery.metadataViewer",
    "roles/iam.serviceAccountViewer",
    "roles/iam.securityReviewer",
  ]
}

resource "google_project_iam_member" "terraform_plan_ci" {
  for_each = toset(local.terraform_plan_ci_roles)
  project  = var.gcp_project
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform_plan_ci.email}"
}

# the gcs backend writes a lock object even for plan, so this SA needs write
# on the state bucket. just that one bucket, not the project. the backend
# block itself cant read variables, so var.state_bucket has to match the
# bucket in env/<env>/backend-config.tfvars by hand.
resource "google_storage_bucket_iam_member" "terraform_plan_ci_state" {
  bucket = var.state_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform_plan_ci.email}"
}
