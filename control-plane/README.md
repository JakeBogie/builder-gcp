# Pivotal Control-Plane on GCP
**An install guide to promote PA mindfulness**

## Prerequisites
The [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) project from [pivotal-cf](https://github.com/pivotal-cf).

The extremely helpful IaaS cleanup tool [leftovers](https://github.com/genevieve/leftovers) from [genevieve](https://github.com/genevieve).

You might find [direnv](https://direnv.net/) useful for this project and also in day to day tasks.

Last but not least you need the [Google Cloud SDK](https://cloud.google.com/sdk/docs/).

Ready to get started?

## STAGE 1 - Control-Plane Preparations

Perform the preparation steps from the parent directory then come back here when you are ready...

### Modify the Terraform variables file
Modify the `control-plane.terraform.tfvars` file replacing any 'ALL CAPS' variables with ones that suit your environment.

  - env_name: This is the `env_name` or `ENV_NAME` variable that was created in the Prerequisites section
  - project: This is your GCP project ID
  - region: This is the region of service you will be using from GCP
  - zones: This is the availability zone selection you will be using from your GCP region
  - dns_suffix: This is the DNS suffix or domain name you will be using for this environment (same as used in the SSL certificate).

```
env_name = "PCF"
project	= "GCP_PROJECT"
region = "REGION"
zones = ["ZONE", "ZONE", "ZONE"]
dns_suffix = "DOMAIN.IO"
opsman_image_url = "https://storage.googleapis.com/YOUR.OPSMAN.IMAGE.URL"
```

### Create the Terraform secrets file
In your `secrets` directory create a file named `control-plane.secrets.terraform.tfvars` with the contents below, replacing the sections noted below with your own data.

__*(In the following three fields paste the contents of your files replacing the `**PASTE_xx_HERE**` portion of each.)*__

  - SSL_CERT: This is the contents of the wildcard SSL certificate you created in the Prerequisites
  - SSL_PRIVATE_KEY: This is the contents of the wildcard SSL certificate key you created in the Prerequisites
  - SERIVICE_ACCOUNT_KEY: This is the contents of the pcf-tform.key.json you created in the Prerequisites

```
ssl_cert = <<SSL_CERT
**PASTE_SSL_CERT_HERE**
SSL_CERT

ssl_private_key = <<SSL_KEY
**PASTE_SSL_PRIVATE_KEY_HERE**
SSL_KEY

service_account_key = <<SERVICE_ACCOUNT_KEY
**PASTE_SERVICE_ACCOUNT_KEY_HERE**
SERVICE_ACCOUNT_KEY
```

## STAGE 2 - Control-Plane IaaS Build
### Initialize Terraform, Create Terraform Plan, and Execute
Initialize the local copy of 'terraforming-gcp'.
```
terraform init /home/abefroman/local-repo/terraforming-gcp/terraforming-pks/

terraform plan -out pcf.plan -var-file pcf.tfvars /home/abefroman/local-repo/terraforming-gcp/terraforming-pks/

terraform apply pcf.plan
```

### Terraform Apply Output
Save the output from the `terraform apply pcf.plan` to a local file. Example: pcf.out. This output will contain IP addressing information along with the URL to login to your Ops Manager.


__You should now have a running Ops Manager that you can configure!__
<!--- SAMPLE COMMENT --->
