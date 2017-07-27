terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/global/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}

resource "aws_vpc" "cloud-lab" {
    cidr_block = "10.10.0.0/22"
    enable_dns_hostnames = true

    tags {
        Name = "cloud-lab"
    }
}

resource "aws_internet_gateway" "cloud-lab-gw" {
    vpc_id = "${aws_vpc.cloud-lab.id}"

    tags {
        Name = "cloud-lab"
    }
}

resource "aws_route_table" "default-egress" {
    vpc_id = "${aws_vpc.cloud-lab.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.cloud-lab-gw.id}"
    }

    tags {
        Name = "cloud-lab"
    }
}

resource "aws_main_route_table_association" "main-route-table" {
    vpc_id         = "${aws_vpc.cloud-lab.id}"
    route_table_id = "${aws_route_table.default-egress.id}"
}

resource "aws_subnet" "10-10-1-0_24" {
    vpc_id                  = "${aws_vpc.cloud-lab.id}"
    cidr_block              = "10.10.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1c"

    tags {
        Name = "10.10.1.0/24"
    }
}

resource "aws_subnet" "10-10-2-0_24" {
    vpc_id                  = "${aws_vpc.cloud-lab.id}"
    cidr_block              = "10.10.2.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1a"

    tags {
        Name = "10.10.2.0/24"
    }
}

resource "aws_security_group" "instance" {
  name   = "cloud-lab"
  vpc_id = "${aws_vpc.cloud-lab.id}"

    # allow all, internal
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["${aws_subnet.10-10-1-0_24.cidr_block}","${aws_subnet.10-10-2-0_24.cidr_block}"]
    }

    # ssh
    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # rdp
    ingress {
        from_port   = "3389"
        to_port     = "3389"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow all
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}