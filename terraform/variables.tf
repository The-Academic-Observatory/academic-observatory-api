variable "google_cloud" {
  description = <<EOF
The Google Cloud settings for the Observatory Platform.

project_id: the Google Cloud project id.
credentials: the Google Cloud credentials in JSON format.
region: the Google Cloud region.
EOF
  type = object({
    project_id  = string
    credentials = string
    region      = string
  })
  sensitive = true
}

variable "name" {
  description = "Name of the API project, e.g. ao or oaebu"
  type        = string
  validation {
    condition     = length(var.name) <= 16
    error_message = "Name of the API has to be <= 16 characters."
  }
}

variable "domain_name" {
  description = "The custom domain name for the API, used for the google cloud endpoints service"
  type        = string
  sensitive   = true
}

variable "backend_image" {
  description = "The image URL that will be used for the Cloud Run backend, e.g. 'us-docker.pkg.dev/your-project-name/observatory-platform/observatory-api:0.3.1'"
  type        = string
  sensitive   = true
}

variable "gateway_image" {
  description = "The image URL that will be used for the Cloud Run gateway (endpoints service), e.g. 'gcr.io/endpoints-release/endpoints-runtime-serverless:2'"
  type        = string
}

variable "api_type" {
  description = <<EOF
Setting related to the specific api type, either the data api or observatory api.
The data api requires the observatory organization and workspace set, while the data api requires the elasticsearch
host and api key set.
EOF
  type = object({
    type                     = string
    observatory_organization = string
    observatory_workspace    = string
    elasticsearch_api_key    = string
    elasticsearch_host       = string
  })
  sensitive = true

  validation {
    condition     = var.api_type.type == "data_api" || var.api_type.type == "observatory_api"
    error_message = "The api type must either be 'data_api' or 'observatory_api'."
  }
  validation {
    condition = (
      var.api_type.type == "data_api" && var.api_type.elasticsearch_host != "" && var.api_type.elasticsearch_api_key != "" ||
      var.api_type.type == "observatory_api" && var.api_type.observatory_organization != "" && var.api_type.observatory_workspace != ""
    )
    error_message = "Elasticsearch host and api key can not be empty when the api type is set to 'data_api' and observatory organization and workspace can not be empty when the api type is set to 'observatory_api'.."
  }
}
