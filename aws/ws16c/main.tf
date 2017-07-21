terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/ws16c/terraform.tfstate"
        region = "us-east-1"
    }
}

module "ws16c-01" {
    instance_count = "${var.instance_count}"
    source         = "../modules/ws16-core"
    admin_password = "${var.admin_password}"
}