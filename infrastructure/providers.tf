terraform {
  required_version = "~> 1.15.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.33.0"
    }
    dbtcloud = {
      source  = "dbt-labs/dbtcloud"
      version = "~> 1.12.4"
    }
  }

  # empty on purpose. the actual bucket/prefix come from
  # env/lab/backend-config.tfvars at init time:
  #   terraform init -backend-config=env/lab/backend-config.tfvars
  # with more envs each one gets its own backend-config plus a terraform
  # workspace, same setup as pfg. the state bucket itself is made by hand
  # (chicken and egg, you need state to manage the bucket that holds the
  # state). in prod you'd give it its own tiny root so its settings arent
  # just a manual claim.
  backend "gcs" {
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# auth comes from variables, the real values live in the gitignored env/lab/vars.tfvars
provider "dbtcloud" {
  account_id = var.dbt_account_id
  token      = var.dbt_token
  host_url   = var.dbt_host_url
}
