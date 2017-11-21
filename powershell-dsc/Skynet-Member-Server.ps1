<#
.SYNOPSIS
    Sample DSC Configuration for joining a server to the lab domain.
.DESCRIPTION
    Sample DSC Configuration for joining a server to the lab domain.

    Standard Config
    ---------------------------
    IPv6           = Disabled
    ICMP FW Rules  = Allow
    SMB FW Rules   = Allow
    HostName       = WS16-01
    Domain Name    = skynet.lab
    NTDS File Path = C:\NTDS
.NOTES

    --------------------------------
    Author: Kevin Kirkpatrick
    Email: kevin@nullzero.io
    GitHub: https:\GitHub.com\vScripter
    Last Updated: 20171120
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Created
#>

# Set a custom DNS Server
#Get-DnsClientServerAddress -InterfaceAlias 'Ethernet 2' ` -AddressFamily IPv4 |
#Set-DnsClientServerAddress -ServerAddresses @('10.10.1.100')

# Clear the DNS cache
#Clear-DNSClientCache

# Disable Server Manager (Desktop Experience Only)
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -Value 1

# Disable IPv6
Get-NetAdapter -Name Ethernet0 | Set-NetAdapterBinding -ComponentID ms_tcpip6 -Enabled:$false

# Install packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module xActiveDirectory -Force
Install-Module xComputerManagement -Force

# Setup FW rules to allow ICMP and SMB
Get-NetFirewallRule -Name *icmp4-erq*|Enable-NetFirewallRule
Get-NetFirewallRule -Name *fps-smb*|Enable-NetFirewallRule

# Start init
Set-Location C:\

configuration DomainMember {

    param(
        [parameter(Mandatory = $true)]
        [PSCredential]$DomainCredential,

        [parameter(Mandatory = $true)]
        [System.String]$HostName
    )

    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xComputerManagement
    Import-DSCResource -ModuleName xActiveDirectory

    Node $AllNodes.Where{$_.Role -eq "MemberServer"}.Nodename {

        # Setup DSC LCM settings
        LocalConfigurationManager
        {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
        }

        # Setup Computer Name
        xComputer ComputerName
        {
            Name = $HostName
        }

        # Domain member config
        xComputer DomainMember {
            Name       = $node.NodeName
            DomainName = $node.DomainName
            Credential = $DomainCredential
            DependsOn  = '[xComputer]ComputerName'
        }

        # Wait for the domain to be available, if necessary
        xWaitForADDomain WaitForDomain
        {
            DomainName       = 'skynet.lab'
            RetryIntervalSec = 120
            RetryCount       = 5
            RebootRetryCount = 3
            DependsOn        = '[xComputer]ComputerName', '[xComputer]DomainMember'
        }

    } # Node

} # configuration

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename                    = "localhost"
            Role                        = "MemberServer"
            DomainName                  = "skynet.lab"
            PsDSCAllowplaintextpassword = $true
        }
    )
} # ConfigData

$splat = @{
    HostName                  = 'WS16-01'
    ConfigurationData         = $ConfigData
    DomainCredential          = (Get-Credential -UserName 'skynet\administrator' -Message 'Domain Admin Credential')
} # splat

DomainMember @splat

# Make sure that LCM is set to continue configuration after reboot
Set-DSCLocalConfigurationManager -Path .\DomainMember –Verbose

# Build the domain
Start-DscConfiguration -Wait -Force -Path .\DomainMember -Verbose

# complete