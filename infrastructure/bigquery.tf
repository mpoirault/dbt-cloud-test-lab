module "bq_datasets" {
  for_each = local.cloud_datasets
  source   = "./modules/bigquery_dataset"

  dataset_id  = each.key
  description = each.value
  location    = var.gcp_region
  project     = var.gcp_project

  labels = {
    managed_by = "terraform"
    runtime    = "dbt_cloud"
    repo       = var.gh_repo_name
  }
}

# the datasets used to be a plain for_each resource in this file. moved blocks
# so terraform tracks them into the module instead of replacing all five.
moved {
  from = google_bigquery_dataset.cloud["cloud_raw"]
  to   = module.bq_datasets["cloud_raw"].google_bigquery_dataset.this
}

moved {
  from = google_bigquery_dataset.cloud["cloud_staging"]
  to   = module.bq_datasets["cloud_staging"].google_bigquery_dataset.this
}

moved {
  from = google_bigquery_dataset.cloud["cloud_intermediate"]
  to   = module.bq_datasets["cloud_intermediate"].google_bigquery_dataset.this
}

moved {
  from = google_bigquery_dataset.cloud["cloud_marts"]
  to   = module.bq_datasets["cloud_marts"].google_bigquery_dataset.this
}

moved {
  from = google_bigquery_dataset.cloud["cloud_seeds"]
  to   = module.bq_datasets["cloud_seeds"].google_bigquery_dataset.this
}
