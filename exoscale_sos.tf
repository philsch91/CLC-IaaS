resource "aws_s3_bucket" "content" {
  bucket = "${var.exoscale_bucket}"
  acl = "public-read"

  lifecycle {
    ignore_changes = [
      "object_lock_configuration"
    ]
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

/*
resource "null_resource" "site" {
  provisioner "local-exec" {
    working_dir = "../"
    command = "s3cmd mb s3://my-new-bucket"    
  }
}
*/

/*
resource "null_resource" "site" {
  provisioner "local-exec" {
    environment {
      JEKYLL_ENV="prod"
    }
    working_dir = "../"
    command = "bundler exec jekyll build --future"
  }
  provisioner "local-exec" {
    working_dir = "../"
    command = "s3cmd sync --config=_terraform/s3.cfg --access_key=${var.exoscale_key} --secret_key=${var.exoscale_secret} --delete-removed ./_site/ s3://${var.content_bucket_name}"
  }
}
*/
