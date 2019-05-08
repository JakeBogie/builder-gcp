# Pivotal Control-Plane on GCP
**An install guide to promote PA mindfulness**

## Prerequisites
The [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) project from [pivotal-cf](https://github.com/pivotal-cf).

The extremely helpful IaaS cleanup tool [leftovers](https://github.com/genevieve/leftovers) from [genevieve](https://github.com/genevieve).

You might find [direnv](https://direnv.net/) useful for this project and also in day to day tasks.

Last but not least you need the [Google Cloud SDK](https://cloud.google.com/sdk/docs/).

Ready to get started?

## STAGE 1 - Preparations

Perform the preparation steps from the parent directory then come back here to finish...



### Modify the Terraform variables file
Modify pcf.tfvars in the project root directory. Replace any 'ALL CAPS' variables with ones that suit your environment.

__*(In the following three fields `ssl_cert | ssl_key, | service_account_key` paste the contents of your files replacing the `PASTE_CERT_HERE` portion of each.)*__
```
env_name = "PCF"
project	= "GCP-PROJECT"
region = "REGION"
zones = ["ZONE", "ZONE", "ZONE"]
dns_suffix = "SUB.DOMAIN.IO"
opsman_image_url = "https://storage.googleapis.com/YOUR.OPSMAN.IMAGE.URL"
```
### Modify the Terraform secrets file
```
ssl_cert = <<SSL_CERT
PASTE CERT HERE
SSL_CERT

ssl_private_key = <<SSL_KEY
PASTE CERT KEY HERE
SSL_KEY

service_account_key = <<SERVICE_ACCOUNT_KEY
PASTE SERVICE ACCOUNT KEY HERE
SERVICE_ACCOUNT_KEY
```

### Example Working Directory Structure
```
builder-gcp-local/
├── README.md
├── keys
│   └── pcf-tform.key.json
├── pcf.tfvars
└── ssl
    ├── private.crt
    ├── private.csr
    ├── private.key
    └── ssl.conf
```

## STAGE 2 - IaaS Build
### Initialize Terraform, Create Terraform Plan, and Execute
Initialize the local copy of 'terraforming-gcp'.
```
terraform init /home/abefroman/local-repo/terraforming-gcp/terraforming-pks/

terraform plan -out pcf.plan -var-file pcf.tfvars /home/abefroman/local-repo/terraforming-gcp/terraforming-pks/

terraform apply pcf.plan
```

### Terraform Apply Output
Save the output from the `terraform apply pcf.plan` to a local file. Example: pcf.out. This output will contain IP addressing information along with the URL to login to your Ops Manager.


### Post Execution Working Directory Structure
```
builder-gcp-local/
├── README.md
├── keys
│   └── pcf-tform.key.json
├── pcf.plan
├── pcf.tfvars
├── ssl
│   ├── private.crt
│   ├── private.csr
│   ├── private.key
│   └── ssl.conf
├── terraform.apply.out
└── terraform.tfstate
```

__You should now have a running Ops Manager that you can configure!__
<!--- SAMPLE COMMENT --->
