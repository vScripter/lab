terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/ws16-lab/member-servers/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "personal-lab-terraform-state"
    key    = "aws/global/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

module "ws16b" {
    source          = "../../modules/ws16-base"
    instance_count  = "${var.instance_count}"
    instance_type   = "${var.instance_type}"
    instance_region = "${var.instance_region}"
    admin_password  = "${var.admin_password}"
}