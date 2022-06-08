# Deploy the API with Terraform
## Set up custom domain name
Register a custom domain that will be used for the API.

## Set up Elasticsearch server
### Create indices
Create indices in Elasticsearch with aliases that map to the aliases defined in the `ElasticsearchIndex` class inside 
`academic_observatory_api/server/elastic.py`.

### Generate API key
Generate and encode an API key, the encoded API key is used for the Terraform variable 'elasticsearch_api_key'. 
When this variable is set, a Google Cloud secret is created and the value is retrieved as an environment variable 
inside the Academic Observatory API by using Berglas.  
To generate an API key, execute in the Kibana Dev console:
```yaml
POST /_security/api_key
{
  "name": "my-dev-api-key",
  "role_descriptors": { 
    "role-read-access-all": {
      "cluster": ["all"],
      "index": [
        {
          "names": ["*"],
          "privileges": ["read", "view_index_metadata", "monitor"]
        }
      ]
    }
  }
}
```  

This returns:
```yaml
{
  "id" : "random_id",
  "name" : "my-dev-api-key",
  "api_key" : "random_api_key"
}
```

Concat id:api_key and base64 encode (this final value is what is used for the Terraform variable 
'elasticsearch_api_key'):
```bash
printf 'random_id:random_api_key' | base64
```

### Get Elasticsearch host address
From the Elastic portal, get the address of the Elasticsearch server. This is used for the Terraform variable 
'elasticsearch_host'. 

## Set up GCP project
### Create service account
Create a service account with the following roles assigned:
* Cloud Run Admin (To create Cloud Run instances)
* Project IAM Admin (To assign permissions to service accounts)
* Secret Manager Admin (To manage the Google Cloud secrets created by env_vars)
* Service Account Admin (To create Cloud Run service accounts)
* Service Account User (To create Cloud Run instances with custom service account)
* Service Management Administrator (To create Cloud Endpoints service)
* Service Usage Admin (To enable Google API services)

### Generate service account JSON key
Create a new JSON key for this service account and format the content in such a way that it can be read as a Terraform variable.
To do this, run the following Python snippet:

```python
import json

with open("/path/to/credentials.json", "r") as f:
    data = f.read()
credentials = json.dumps(data)
```

Copy the 'credentials' value and use it for the 'google_cloud' Terraform variable, see below.

### Add service account as verified domain owner
In order to create a domain mapping between the generated domain of the Cloud Run gateway service and a custom 
domain, the service account has to be added as a verified domain owner, see the 
[Google Docs](https://cloud.google.com/run/docs/mapping-custom-domains#add-verified) for more information.

## Create a Docker image
Build a Docker image and push to the Google Artifact Registry with the Github workflow in this repository.  
This workflow is automatically triggered by any of the following:
- Push to the 'develop' or 'main' branch
- Pull request event with the 'develop' or 'main' branch as target
- Publishing a new release

The URL of this image on the Artifact Registry is used for the 'backend_image' Terraform variable, see below.

## Create a Terraform workspace
Create a Terraform workspace and set up the following variables:

| Variable      | Example                                                                                                                                                                                                               | HCL | Sensitive |
|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----|-----------|
| google_cloud  | {<br/>"project_id"="my-project-id",<br/>"credentials"="json-credentials",<br/>"region="us-central1"<br/>}                                                                                                             | Yes | Yes       |
| name          | ao                                                                                                                                                                                                                    | No  | No        |
| domain_name   | my-project-id.ao.api.observatory.academy                                                                                                                                                                              | No  | Yes       |
| backend_image | us-docker.pkg.dev/your-project-name/observatory-platform/observatory-api:0.3.1                                                                                                                                        | No  | Yes       |
| gateway_image | gcr.io/endpoints-release/endpoints-runtime-serverless:2                                                                                                                                                               | No  | No        |
| api_type      | {<br/>"type"="data_api",<br/>"observatory_organization"="",<br/>"observatory_workspace"="",<br/>elasticsearch_host="https://my-project-id.es.us-west1.gcp.cloud.es.io:9243",<br/>elasticsearch_api_key="APIKEY"<br/>} | Yes | Yes       |

## Create cloud resources with Terraform
Enter 'terraform' directory inside this repository
```
$ cd terraform
```

From inside the 'terraform' directory, plan/apply Terraform configuration
```
$ terraform init
$ terraform plan
$ terraform apply
```
