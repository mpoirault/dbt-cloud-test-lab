resource "google_bigquery_dataset" "this" {
  # checkov:skip=CKV_GCP_81: CMEK is overkill for a personal lab, google managed
  # encryption is fine. revisit before putting real data in here.

  dataset_id  = var.dataset_id
  description = var.description
  location    = var.location
  project     = var.project

  delete_contents_on_destroy = false

  labels = var.labels
}
