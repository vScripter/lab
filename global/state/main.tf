
terraform {
  backend "s3" {
    bucket = "personal-lab-terraform-state"
    key    = "global/state/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
# bucket name must be globally unique
    bucket = "${var.bucket_name}"
    acl = "private"

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }
}