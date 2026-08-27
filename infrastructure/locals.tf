locals {
  # the runner SA key, decoded once here so dbt_cloud.tf can pick fields out of it
  sa_key_json = jsondecode(base64decode(google_service_account_key.dbt_cloud_runner.private_key))

  cloud_datasets = {
    cloud_raw          = "Landing zone for ingested data (dbt Cloud)."
    cloud_staging      = "dbt Cloud staging layer (1:1 with sources, light typing/renaming)."
    cloud_intermediate = "dbt Cloud intermediate layer (joins, business logic building blocks)."
    cloud_marts        = "dbt Cloud marts layer (consumption-ready models)."
    cloud_seeds        = "dbt Cloud seeds layer (raw data for seeding models)."
  }
}
