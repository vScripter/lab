terraform {
    backend "s3" {
        bucket = "personal-lab-terraform-state"
        key    = "aws/ws16-lab/dc-01/terraform.tfstate"
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

provider "aws" {
    region = "${var.dc_config.["instance_region"]}"
}

data "aws_ami" "ws16b" {
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

# Primary Domain Controller
resource "aws_instance" "ws16b" {
  count                  = "${var.dc_config.["instance_count"]}"
  ami                    = "${data.aws_ami.ws16b.id}"
  instance_type          = "${var.dc_config.["instance_type"]}"
  key_name               = "${var.dc_config.["aws_key_pair"]}"
  #subnet_id              = "${data.terraform_remote_state.vpc.subnet_id}"
  #vpc_security_group_ids = ["${data.terraform_remote_state.vpc.instance_sg}"]
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
  Rename-Computer -NewName "${var.dc_config.["instance_name"]}" -Restart -Confirm:$False
</powershell>
EOF

  network_interface {
    device_index          = 0
    network_interface_id  = "${aws_network_interface.int0.id}"
    #private_dns           = ["${aws_network_interface.int0.private_ips}"]
  }

  tags {
    Name = "${var.dc_config.["instance_name"]}"
  }
}

resource "aws_network_interface" "int0" {
    subnet_id       = "${data.terraform_remote_state.vpc.subnet_10-10-1-0_24_id}"
    private_ips     = ["10.10.1.100"]
    security_groups = ["${data.terraform_remote_state.vpc.instance_sg}"]

    tags {
        Name = "primary_network_interface"
  }
}