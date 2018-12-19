env_name = "PCF"
project	= "GCP-PROJECT"
region = "REGION"
zones = ["ZONE", "ZONE", "ZONE"]
dns_suffix = "SUB.DOMAIN.IO"
opsman_image_url = "https://storage.googleapis.com/YOUR.OPSMAN.IMAGE.URL"
buckets_location = "US"

ssl_cert = <<SSL_CERT
*PASTE CERT HERE*
SSL_CERT

ssl_private_key = <<SSL_KEY
*PASTE CERT KEY HERE*
SSL_KEY

service_account_key = <<SERVICE_ACCOUNT_KEY
*PASTE SERVICE ACCOUNT KEY HERE*
SERVICE_ACCOUNT_KEY
