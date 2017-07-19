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

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "personal-lab-terraform-state"
    key    = "aws/global/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

/*resource "aws_network_interface" "int0" {
    subnet_id             = "${data.terraform_remote_state.vpc.subnet_id}"
    security_groups       = ["${aws_security_group.instance.id}"]


    tags {
        Name = "primary_network_interface"
  }
}*/

resource "aws_security_group" "instance" {
  name = "cloud-lab"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = "3389"
        to_port     = "3389"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "ubuntu-dev" {
    count           = 2
    ami             = "ami-9a0c088c" # ubuntu 16.04 LTS (HVM) - US-East-1
    instance_type   = "t2.micro"
    key_name        = "kevin-general"
    subnet_id       = "${data.terraform_remote_state.vpc.subnet_id}"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]

    /*network_interface {
        network_interface_id  = "${aws_network_interface.int0.id}"
        device_index          = 0
        delete_on_termination = true
    }*/

    tags {
        Name = "${var.nix_hostname_prefix}-${count.index}"
    }
}

resource "aws_instance" "ws16-core" {
    count           = 2
    ami             = "ami-a62402b0" # WS16 Core w/ Containers - US-East-1
    instance_type   = "t2.micro"
    key_name        = "kevin-general"
    subnet_id       = "${data.terraform_remote_state.vpc.subnet_id}"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]

    tags {
        Name = "${var.ws_hostname_prefix}-${count.index}"
    }
}