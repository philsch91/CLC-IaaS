provider "exoscale" {
  key = "${var.exoscale_key}"
  secret = "${var.exoscale_secret}"
}

provider "aws" {
  access_key = "${var.exoscale_key}"
  secret_key = "${var.exoscale_secret}"
  
  region = "de-muc-1"
  skip_metadata_api_check = true
  skip_credentials_validation = true
  skip_region_validation = true
  skip_get_ec2_platforms = true
  skip_requesting_account_id = true
  
  endpoints {
    s3 = "https://sos-de-muc-1.exo.io"
    s3control = "https://sos-de-muc-1.exo.io"
  }
}
