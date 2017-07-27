
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

/*
module "ws16b" {
    instance_count = "${var.instance_count}"
    source         = "../modules/ws16-base"
    admin_password = "${var.admin_password}"
}*/

/*

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

# Primary Domain Controller
resource "aws_instance" "ws16_pdc" {
  count                  = "${var.instance_count}"
  ami                    = "${data.aws_ami.ws16_base.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.aws_key_pair}"
  #subnet_id              = "${data.terraform_remote_state.vpc.subnet_id}"
  vpc_security_group_ids = ["${data.terraform_remote_state.vpc.instance_sg}"]
  #user_data              = "${data.template_file.user_data.rendered}"
  user_data              = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Install-Module xActiveDirectory -Force; Install-Module xComputerManagement -Force
</powershell>
<powershell>
  configuration CloudLabDomain
{
   param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred,
        [Parameter(Mandatory)]
        $DesiredHostname
    )

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xComputerManagement

    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {

        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyAndMonitor'
            RebootNodeIfNeeded = $true
        }

        xComputer HostName
        {
            Name = $DesiredHostname
        }

        File ADFiles
        {
            DestinationPath = 'C:\NTDS'
            Type = 'Directory'
            Ensure = 'Present'
        }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        # Optional GUI tools
        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS"
        }

        # No slash at end of folder paths
        xADDomain FirstDS
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DatabasePath                  = 'C:\NTDS'
            LogPath                       = 'C:\NTDS'
            DependsOn                     = "[WindowsFeature]ADDSInstall","[File]ADFiles","[xComputer]Hostname"
        }

    }
}

# Configuration Data for AD
$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            Role = "Primary DC"
            DomainName = "cloud.lab"
            RetryCount = 20
            RetryIntervalSec = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
}

$splat = @{
    ConfigurationData = $ConfigData
    SafemodeAdministratorCred = (Get-Credential -UserName '(Password Only)' -Message "New Domain Safe Mode Administrator Password")
    DomainCred = (Get-Credential -UserName cloud\administrator -Message "New Domain Admin Credential")
    DesiredHostName = 'ws16b-dc01'

}

CloudLabDomain @splat

<#
CloudLabDomain -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' -Message "New Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName cloud\administrator -Message "New Domain Admin Credential")
    #>

# Make sure that LCM is set to continue configuration after reboot
Set-DSCLocalConfigurationManager -Path .\CloudLabDomain -Verbose

# Build the domain
Start-DscConfiguration -Wait -Force -Path .\CloudLabDomain -Verbose
</powershell>
EOF

  network_interface {
    device_index          = 0
    network_interface_id  = "${aws_network_interface.int0.id}"
    delete_on_termination = true
    #private_dns           = ["${aws_network_interface.int0.private_ips}"]
  }

  tags {
    Name = "${var.instance_name}-${count.index}"
  }
}

resource "aws_network_interface" "int0" {
    subnet_id       = "${data.terraform_remote_state.vpc.subnet_id}"
    private_ips     = "[10.10.1.100]"
    security_groups = ["${aws_security_group.instance.id}"]


    tags {
        Name = "primary_network_interface"
  }
}

*/