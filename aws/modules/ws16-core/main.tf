terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/modules/ws16-core/terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "${var.instance_region}"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "personal-lab-terraform-state"
    key    = "aws/global/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "ws16_core" {
  most_recent = true
  owners      = ["801119661308"] # Microsoft

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Core-Containers-*"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.txt")}"

  vars {
    password       = "${var.admin_password}"
    hostname       = "${var.instance_name}"
  }
}

resource "aws_instance" "ws16_core" {
  count                  = "${var.instance_count}"
  ami                    = "${data.aws_ami.ws16_core.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.aws_key_pair}"
  subnet_id              = "${data.terraform_remote_state.vpc.subnet_id}"
  vpc_security_group_ids = ["${data.terraform_remote_state.vpc.instance_sg}"]
  user_data              = "${data.template_file.user_data.rendered}"

  tags {
    Name = "${var.instance_name}-${count.index}"
  }
}

/*resource "aws_network_interface" "int0" {
    subnet_id             = "${data.terraform_remote_state.vpc.subnet_id}"
    security_groups       = ["${aws_security_group.instance.id}"]


    tags {
        Name = "primary_network_interface"
  }
}*/