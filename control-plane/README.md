# Pivotal Control-Plane on GCP
**An install guide to promote PA mindfulness**

For additional reading and help you can visit the docs site for [Control-Plane](https://control-plane-docs.cfapps.io/).

## Prerequisites
The [terraforming-gcp](https://github.com/pivotal-cf/terraforming-gcp/) project from [pivotal-cf](https://github.com/pivotal-cf).

The extremely helpful IaaS cleanup tool [leftovers](https://github.com/genevieve/leftovers) from [genevieve](https://github.com/genevieve).

You might find [direnv](https://direnv.net/) useful for this project and also in day to day tasks.

Last but not least you need the [Google Cloud SDK](https://cloud.google.com/sdk/docs/).

Ready to get started?

## STAGE 1 - Control-Plane preparations
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
In your `secrets` directory create a file named `control-plane.secrets.tfvars` with the contents below, replacing the sections noted below with your own data.

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

## STAGE 2 - Control-Plane IaaS build
### Initialize Terraform, Create Terraform Plan, and Execute
Change directory into the local copy of `terraforming-gcp/terraforming-control-plane` and perform the following commands (edit to reflect your file paths). These commands will create two new files `control-plane.terraform.plan` and `control-plane.terraform.out` and they contain sensitive data so be sure to redirect them to your `secrets` directory.
```
terraform init

terraform plan -out /path/to/your/secrets/control-plane.terraform.plan -var-file /path/to/your/control-plane.terraform.tfvars -var-file /path/to/your/secrets/control-plane.secrets.tfvars

terraform apply -state-out /path/to/your/secrets/control-plane.terraform.out /path/to/your/secrets/control-plane.terraform.plan
```

### Terraform apply output
Copy the terminal output from the `terraform apply` command to a local file. Example: 'control-plane.output' This output will contain IP addressing information along with the URL to login to your Ops Manager.

You can also use the `terraform output` command to parse your `control-plane.terraform.out` configuration settings applied by the Terraform apply command.

### DNS changes
You will now need to make changes to the authoritative DNS servers for the zone (domain) that you are using for this environment. Making those changes are beyond the scope of this walkthrough. The name servers for your environment in GCP were allocated by the Terraform commands. This can be located in your `control-plane.output` file as the variable named `env_dns_zone_name_servers`.

## STAGE 3 - Configure your Ops Manager & BOSH Director
### Ops Manager Select an Authentication System
Using a browser navigate to the URL for your Ops Manager. This can be located in your `control-plane.output` file as the variable named `ops_manager_dns`. It is recommended for this walkthrough that you use the `Internal Authentication` setting.

When redirected to the Internal Authentication page, do the following:

  - Enter a Username, Password, and Password confirmation to create an Admin user.
  - Enter a Decryption passphrase and the Decryption passphrase confirmation. This passphrase encrypts the Ops Manager datastore, and is not recoverable if lost.
  - Read the End User License Agreement, and select the checkbox to accept the terms.
  - Click Setup Authentication.

After a few moment of processing you should be able to login to your Ops Manager.

### Ops Manager SSL certificate & Pivnet token
Once logged into your Ops Manager instance navigat to the top right corner of the page and click your username and go to the 'Settings' page. On the left navigation bar click on 'SSL Certificate'. Here you will enter the contents of your wildcard SSL certificate and wildcard SSL certificate key files then click 'Add Certificate'.

On the left navigation bar click on 'Pivotal Network Settings' and enter your Pivotal Network Legacy API token into the field 'Set API Token'. Click 'Add Token' to save the token.

You should now be able to log out of the Ops Manager instance and log back in with a trusted SSL connection.

### BOSH Director
Use the values provided by your `control-plane.output` to configure the BOSH Director. Use this guide to learn step by step how to configure your director for your GCP.

**Note**: On the `Create Networks Page` only create one network, following the `infrastructure` network guide, and set the `Name` field to `control-plane-subnet`.

[Configuring BOSH Director on GCP](https://docs.pivotal.io/pivotalcf/2-4/om/gcp/config-terraform.html)

<!--- SAMPLE COMMENT --->
