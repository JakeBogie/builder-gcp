# Pivotal stuff on GCP for Platform Architects
**An install guide to promote PA mindfulness**

## Prerequisites
The [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) project from [pivotal-cf](https://github.com/pivotal-cf).

The extremely helpful IaaS cleanup tool [leftovers](https://github.com/genevieve/leftovers) from [genevieve](https://github.com/genevieve).

You might find [direnv](https://direnv.net/) useful for this project and also in day to day tasks.

Last but not least you need the [Google Cloud SDK](https://cloud.google.com/sdk/docs/).

Ready to get started?

## STAGE 1 - Preparations
These preparation steps should be completed no matter what you are installing: Control-Plane, PAS, or PKS.

### Pick an Environment Name
You will be replacing variables shortly that will require this name. Choose a name that you will be comfortable with. Example: pcfv1

### Clone the terraforming-gcp repository
In this local working directory clone the [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) repository for use.

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

### Modify your .envrc file
Change the `BBL_GCP_SERVICE_ACCOUNT_KEY` variable path to the absolute path of your pcf-tform.key.json file that you created in the step above.
```
export BBL_GCP_SERVICE_ACCOUNT_KEY=/home/abefroman/terraform/gcp/keys/pcf-tform.key.json
```
