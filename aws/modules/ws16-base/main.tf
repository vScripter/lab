terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/modules/ws16-base/terraform.tfstate"
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

data "aws_ami" "ws16_base" {
    most_recent = true
    owners      = ["801119661308"] # Microsoft
    filter {
        name   = "name"
        values = ["Windows_Server-2016-English-Full-Base-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "platform"
        values = ["windows"]
    }

    filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

/*
data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.txt")}"

  vars {
    password       = "${var.admin_password}"
    hostname       = "${var.instance_name}"
  }
}
*/

resource "aws_instance" "ws16_base" {
  count                  = "${var.instance_count}"
  ami                    = "${data.aws_ami.ws16_base.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.aws_key_pair}"
  subnet_id              = "${data.terraform_remote_state.vpc.subnet_10-10-1-0_24_id}"
  vpc_security_group_ids = ["${data.terraform_remote_state.vpc.instance_sg}"]
  #user_data              = "${data.template_file.user_data.rendered}"
  user_data              = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.admin_password}")
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Install-Module xActiveDirectory -Force
  Install-Module xComputerManagement -Force
  Get-NetFirewallRule -Name *icmp4-erq*|Enable-NetFirewallRule
  Get-NetFirewallRule -Name *fps-smb*|Enable-NetFirewallRule
  Rename-Computer -NewName "${var.instance_name}-${count.index}" -Restart -Confirm:$False
</powershell>
EOF

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