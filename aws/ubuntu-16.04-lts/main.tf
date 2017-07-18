terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/ubuntu-16.04-lts/terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

data "terraform_remote_state" "vpc_subnet" {
  backend = "s3"

  config {
    bucket = "personal-lab-terraform-state"
    key    = "aws/global/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_network_interface" "int0" {
  subnet_id = "${data.terraform_remote_state.vpc_subnet.subnet_id}"
  tags {
      Name = "primary_network_interface"
  }
}

resource "aws_instance" "ubuntu-dev" {
    ami = "ami-9a0c088c"
    instance_type = "t2.micro"
    key_name = "kevin-general"

    network_interface {
        network_interface_id = "${aws_network_interface.int0.id}"
        device_index = 0
    }

    tags {
        Name = "${var.instance_name}"
    }
}