# Deploy the API with Terraform
## Set up custom domain name
Register a custom domain that will be used for the API.

## Create OpenAPI template
Create the OpenAPI.yaml.tpl file, this is a template file that will be used by the Terraform configuration of the 
API module for the Cloud Endpoints service.
The file should be stored inside the `terraform` directory of this repository, in the same directory as the 'main.tf' configuration file.

To generate this template using the `generate-openapi-spec` command from the 
[coki-api-base](https://github.com/The-Academic-Observatory/coki-api-base) library:

```
$ coki-api-base generate-openapi-spec academic_observatory_api/openapi.yaml.jinja2 terraform/openapi.yaml.tpl 
--usage-type cloud_endpoints
```

## Set up Elasticsearch server
### Create indices
Create indices in Elasticsearch with aliases that map to the aliases defined in the `ElasticsearchIndex` class inside 
`academic_observatory_api/server/elastic.py`.

### Generate API key
Generate and encode an API key, the encoded API key is used for the Terraform variable 'elasticsearch_api_key'. 
When this variable is set, a Google Cloud secret is created and the value is retrieved as an environment variable 
inside the Academic Observatory API by using Berglas.  
To generate an encoded API key, execute in the Kibana Dev console:
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
  "encoded" : "random_id:random_api_key base64 encoded"
}
```

The value of the returned "encoded" field is used for the Terraform variable 'elasticsearch_api_key'.

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
Create a new JSON key for this service account and remove the newlines so that it can be read as a Terraform 
environment variable.
To do this, either run in the terminal:
```shell
cat /path/to/credentials.json | tr '\n' ' '
```

Or run the following Python snippet:

```python
with open("/path/to/credentials.json", "r") as f:
    credentials = f.read().replace("\n", "")
```

Copy the terminal output or 'credentials' value and use it for the 'google_cloud' Terraform variable, see below.

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
Create a Terraform Cloud workspace, add the 'academic-observatory-api' tag and set up the following variables:

```eval_rst
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| Variable                | Env | HCL | Sensitive | Example                                                                        |
+=========================+=====+=====+===========+================================================================================+
| GOOGLE_CREDENTIALS      | Yes | NA  |    Yes    | <json-credentials>                                                             |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| google_cloud            | No  | Yes |    No     | {"project_id"="my-project-id","region"="us-central1"}                          |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| name                    | No  | No  |    No     | ao                                                                             |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| domain_name             | No  | No  |    No     | my-project-id.ao.api.observatory.academy                                       |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| backend_image           | No  | No  |    No     | us-docker.pkg.dev/your-project-name/observatory-platform/observatory-api:0.3.1 |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| gateway_image           | No  | No  |    No     | gcr.io/endpoints-release/endpoints-runtime-serverless:2                        |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| elasticsearch_host      | No  | No  |    No     | https://my-project-id.es.us-west1.gcp.cloud.es.io:9243                         |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
| elasticsearch_api_key   | No  | No  |    Yes    | <encoded-api-key>                                                              |
+-------------------------+-----+-----+-----------+--------------------------------------------------------------------------------+
```

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
