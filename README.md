# Pivotal PCF on GCP for Platform Architects
**An install guide to promote PA mindfulness**

## Prerequisites
The [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) project from [pivotal-cf](https://github.com/pivotal-cf).

The extremely helpful IaaS cleanup tool [leftovers](https://github.com/genevieve/leftovers) from [genevieve](https://github.com/genevieve).

You might find [direnv](https://direnv.net/) useful for this project and also in day to day tasks.

Last but not least you need the [Google Cloud SDK](https://cloud.google.com/sdk/docs/).

Ready to get started?

## STAGE 1 - Preparations
These preparation steps should be completed no matter what you are installing: Control-Plane, PAS, or PKS.

### Pick an Environment name
You will be replacing variables shortly that will require this name. Choose a name that you will be comfortable with. Example: `pcfv1`. This will be used later on as the following two variables: `env_name` and `ENV_NAME`

### Clone the terraforming-gcp repository
Clone the [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) repository for use.

### Enable GCP API Access for the following APIs:
Login to your GCP console and search for APIs & Services. Enable each of the APIs listed below:

  - Identity and Access Management
  - Cloud Resource Manager
  - Cloud DNS
  - Cloud SQL API
  - Compute Engine API

Alternately you can perform the following steps via the Google Cloud SDK
```
gcloud services enable iam.googleapis.com --async
gcloud services enable cloudresourcemanager.googleapis.com --async
gcloud services enable dns.googleapis.com --async
gcloud services enable sqladmin.googleapis.com --async
gcloud services enable compute.googleapis.com --async
```

### GCP Service Account Setup:
Create a secure method of storing credentials and secrets someplace. You will be storing access keys, SSH keys, and certificates in this location. Choose wisely and don't commit credentials out to public repositories.

Perform the following steps in the `secrets` directory and replace the variable `GCP-PROJECT` in the following commands with your GCP project ID.
```
gcloud iam service-accounts create pcf-tform --display-name "PCF Terraform Service Account"

gcloud iam service-accounts keys create "pcf-tform.key.json" --iam-account "pcf-tform@GCP-PROJECT.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding GCP-PROJECT --member 'serviceAccount:pcf-tform@GCP-PROJECT.iam.gserviceaccount.com' --role 'roles/owner'
```

### Modify the base directory .envrc file
Change the `BBL_GCP_SERVICE_ACCOUNT_KEY` variable path to the absolute path of your pcf-tform.key.json file that you created in the step above.
```
export BBL_IAAS=gcp
export BBL_GCP_SERVICE_ACCOUNT_KEY=/home/abefroman/terraform/gcp/keys/pcf-tform.key.json
```

### Create a SSL config file
In your `secrets` directory copy the contents below into an `ssl.conf` file. Replace all of the following variables with the names you will be using:

  - `DOMAIN.IO` this variable is for the domain name that you will be using.
  - `ENV_NAME`  this variable is the one you created above.

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
commonName_default          = *.ENV_NAME.DOMAIN.IO

[ req_ext ]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.ENV_NAME.DOMAIN.IO
DNS.2 = *.sys.ENV_NAME.DOMAIN.IO
DNS.3 = *.apps.ENV_NAME.DOMAIN.IO
DNS.5 = *.login.system.ENV_NAME.DOMAIN.IO
DNS.6 = *.uaa.system.ENV_NAME.DOMAIN.IO
```

### Create a wildcard SSL certificate for all of your PCF components (browser SSL errors are annoying)
Perform the following steps in your `secrets` directory.

```
openssl genrsa -out wildcard.ENV_NAME.DOMAIN.IO.key 2048

openssl req -new -sha256 -key wildcard.ENV_NAME.DOMAIN.IO.key -out wildcard.wildcard.ENV_NAME.DOMAIN.IO.csr -config wildcard.ENV_NAME.DOMAIN.IO.conf
```

Use this command to sign the cert with it's own key. __See below if you have a CA cert you can sign with.__

```
openssl x509 -req -in wildcard.ENV_NAME.DOMAIN.IO.csr -out wildcard.ENV_NAME.DOMAIN.IO.io.crt2 -days 3650 -sha256 -extensions req_ext -extfile wildcard.ENV_NAME.DOMAIN.IO.conf -signkey wildcard.ENV_NAME.DOMAIN.IO.key
```

Use this command __if you have a CA cert__ that you can sign the cert with that you trust. :)

```
openssl x509 -req -in wildcard.ENV_NAME.DOMAIN.IO.csr -CA ../ca/bogie.io.pem -CAkey ../ca/bogie.io.key -CAcreateserial -out wildcard.ENV_NAME.DOMAIN.IO.crt -days 3650 -sha256 -extensions req_ext -extfile wildcard.ENV_NAME.DOMAIN.IO.conf
```

__You are now ready to move on to building either a Control-Plane, PAS, or PKS instance.__
