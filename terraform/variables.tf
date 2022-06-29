variable "google_cloud" {
  description = <<EOF
The Google Cloud settings for the Observatory Platform.

project_id: the Google Cloud project id.
region: the Google Cloud region.
EOF
  type = object({
    project_id = string
    region     = string
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

variable "elasticsearch_host" {
  description = "The address of the Elasticsearch server, e.g. "
  type        = string
}

variable "elasticsearch_api_key" {
  description = "An API key for the Elasticsearch server"
  type        = string
}