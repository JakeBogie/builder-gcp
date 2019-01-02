# Pivotal PKS on GCP
**An install guide to promote mindfulness**

## Prerequisites
The [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) project from [pivotal-cf](https://github.com/pivotal-cf).

The extremely helpful IaaS cleanup tool [leftovers](https://github.com/genevieve/leftovers) from [genevieve](https://github.com/genevieve).

You might find [direnv](https://direnv.net/) useful for this project and also in day to day tasks.

Last but not least you need the [Google Cloud SDK](https://cloud.google.com/sdk/docs/).

Ready to get started?

## STAGE 1 - Local Build & Config
### Enable GCP API Access for the following APIs:
Login to your GCP console and search for APIs & Services.

  - Identity and Access Management
  - Cloud Resource Manager
  - Cloud DNS
  - Cloud SQL API
  - Compute Engine API

### GCP Service Account Setup:
Perform the following steps in the 'keys' directory and replace the variable `GCP-PROJECT` in the following commands with your GCP project ID.
```
gcloud iam service-accounts create pcf-tform --display-name "PCF Terraform Service Account"

gcloud iam service-accounts keys create "pcf-tform.key.json" --iam-account "pcf-tform@GCP-PROJECT.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding GCP-PROJECT --member 'serviceAccount:pcf-tform@GCP-PROJECT.iam.gserviceaccount.com' --role 'roles/owner'
```

### Modify your .envrc file
Change the path to the absolute path of your pcf-tform.key.json file.
```
export BBL_GCP_SERVICE_ACCOUNT_KEY=/home/abefroman/terraform/gcp/keys/pcf-tform.key.json
```

### Pick an Environment Name
You will be replacing variables shortly that will require this name. Choose a name that you will be comfortable with. Example: pksv1.

### Modify the SSL Config File
In the 'ssl' directory modify the contents of the ssl.conf file to suit your environment. Replace all of the variables in 'ALL CAPS' with the domain name you will be using.

__*(This example uses RSA-2048 encryption. Currently, only RSA-2048 and ECDSA P-256 encryption are supported by GCP Load Balancers.)*__
```
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = US
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = Illinois
localityName                = Locality Name (eg, city)
localityName_default        = Chicago
organizationName            = Organization Name (eg, company)
organizationName_default    = Froman\'s Fine Meats
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_max              = 64
commonName_default          = *.DOMAIN.IO

[ req_ext ]
subjectAltName = @alt_names

[alt_names]
DNS.1   = *.SUB.DOMAIN.IO
DNS.2   = *.ENV_NAME.SUB.DOMAIN.IO
DNS.3	= *.sys.ENV_NAME.SUB.DOMAIN.IO
DNS.4	= *.apps.ENV_NAME.SUB.DOMAIN.IO
DNS.5	= *.ws.pcf.ENV_NAME.DOMAIN.IO
```

### Create the SSL Certificate
Perform this step in the 'ssl' directory.
```
openssl genrsa -out private.key 2048

openssl req -new -sha256 -out private.csr -key private.key -config ssl.conf

openssl x509 -req -days 3650 -in private.csr -signkey private.key -out private.crt -extensions req_ext -extfile ssl.conf
```

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
buckets_location = "us"

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
