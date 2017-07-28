
terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/ws16b/terraform.tfstate"
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

resource "aws_directory_service_directory" "ms_directory" {
  name     = "cloud.lab"
  password = "${var.admin_password}"
  short_name = "cloud"
  type = "MicrosoftAD"

  vpc_settings {
    vpc_id     = "${data.terraform_remote_state.vpc.vpc_id}"
    subnet_ids = ["${data.terraform_remote_state.vpc.subnet_10-10-1-0_24_id}","${data.terraform_remote_state.vpc.subnet_10-10-2-0_24_id}"]
  }
}