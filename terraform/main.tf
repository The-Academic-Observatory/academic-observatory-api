terraform {
  cloud {
    workspaces {
      tags = ["academic-observatory-api"]
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.85.0"
    }
  }
}

provider "google" {
  project = var.google_cloud.project_id
  region  = var.google_cloud.region
}


module "api" {
  source        = "The-Academic-Observatory/api/google"
  version       = "0.0.9"
  name          = var.name
  domain_name   = var.domain_name
  backend_image = var.backend_image
  gateway_image = var.gateway_image
  google_cloud  = var.google_cloud
  env_vars = {
    "ES_HOST"    = var.elasticsearch_host,
    "ES_API_KEY" = var.elasticsearch_api_key,
  }
  cloud_run_annotations = {
    "autoscaling.knative.dev/maxScale" = "10"
  }
}
