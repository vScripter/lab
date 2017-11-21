<#
.SYNOPSIS
    Sample DSC Configuration for joining a server to the lab domain.
.DESCRIPTION
    Sample DSC Configuration for joining a server to the lab domain.

    This is written to run on a brand new installation of WS 2016.

    Internet Access is REQUIRED.

    Standard Config
    ---------------------------
    IPv6           = Disabled
    IPv4           = 192.168.100.201/24
    Gateway        = 192.168.100.2
    DNS            = 192.168.100.200, 208.67.222.22
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

# Set local admin password to never export
Get-LocalUser -Name Administrator | Set-LocalUser -PasswordNeverExpires:$True

# Disable Server Manager (Desktop Experience Only)
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -Value 1

# Disable IPv6
Get-NetAdapter -Name Ethernet0 | Set-NetAdapterBinding -ComponentID ms_tcpip6 -Enabled:$false

# Install packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module xActiveDirectory -Force
Install-Module xComputerManagement -Force
Install-Module xNetworking -Force
Install-Module xRemoteDesktopAdmin -Force

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
        [System.String]$HostName,

        [parameter(Mandatory = $true)]
        [System.String]$InterfaceAlias,

        [parameter(Mandatory = $true)]
        [System.String]$IPv4Address,

        [parameter(Mandatory = $true)]
        [System.String]$Eth0Gateway,

        [parameter(Mandatory = $true)]
        [System.String[]]$Eth0DnsAddress


    )

    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xComputerManagement
    Import-DSCResource -ModuleName xActiveDirectory
    Import-DSCResource -ModuleName xNetworking
    Import-DSCResource -ModuleName xRemoteDesktopAdmin

    Node $AllNodes.Where{$_.Role -eq "MemberServer"}.Nodename {

        # Setup DSC LCM settings
        LocalConfigurationManager
        {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
        }

        # Enable Remote Desktop
        xRemoteDesktopAdmin EnableRDP
        {
            Ensure             = 'Present'
            UserAuthentication = 'NonSecure'
        }

        # IP Address
        xIPAddress Eth0IP
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $InterfaceAlias
            IPAddress      = $IPv4Address
        }

        # DNS Settings
        xDNSServerAddress Eth0DNS
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $InterfaceAlias
            Address        = $Eth0DnsAddress
        }

        # Default Gateway
        xDefaultGatewayAddress Eth0Gateway
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $InterfaceAlias
            Address        = $Eth0Gateway
        }

        # Setup Computer Name
        xComputer ComputerName
        {
            Name      = $HostName
            DependsOn = '[xIPAddress]Eth0IP', '[xDNSServerAddress]Eth0DNS', '[xDefaultGatewayAddress]Eth0Gateway'
        }

        # Wait for the domain to be available, if necessary
        xWaitForADDomain WaitForDomain
        {
            DomainName       = 'skynet.lab'
            RetryIntervalSec = 15
            RetryCount       = 5
            RebootRetryCount = 3
            DependsOn        = '[xComputer]ComputerName'
        }

        # Domain member config
        xComputer DomainMember {
            Name       = $node.NodeName
            DomainName = $node.DomainName
            Credential = $DomainCredential
            DependsOn  = '[xWaitForADDomain]WaitForDomain'
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

$configurationParams = @{
    HostName                  = 'WS16-01'
    InterfaceAlias            = 'Ethernet0'
    IPv4Address               = '192.168.100.201/24'
    Eth0DnsAddress            = '192.168.100.200', '208.67.222.222'
    Eth0Gateway               = '192.168.100.2'
    ConfigurationData         = $ConfigData
    DomainCredential          = (Get-Credential -UserName 'skynet\administrator' -Message 'Domain Admin Credential')
} # configurationParams

# Invoke the configruation
DomainMember @configurationParams

# Make sure that LCM is set to continue configuration after reboot
Set-DSCLocalConfigurationManager -Path .\DomainMember –Verbose

# Build the domain
Start-DscConfiguration -Wait -Force -Path .\DomainMember -Verbose

# complete