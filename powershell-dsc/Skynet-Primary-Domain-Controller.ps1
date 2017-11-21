<#
.SYNOPSIS
    Sample DSC Configuration for standing up a Domain controller.
.DESCRIPTION
    Sample DSC Configuration for standing up a Domain controller.

    This is written to run on a brand new installation of WS 2016.

    Internet Access is REQUIRED.

    Standard Config
    ---------------------------
    IPv6               = Disabled
    IPv4               = 192.168.100.200/24
    Gateway            = 192.168.100.2
    DNS                = 127.0.0.1,208.67.222.22
    ICMP FW Rules      = Allow
    SMB FW Rules       = Allow
    HostName           = PDC
    Domain Name        = skynet.lab
    NTDS File Path     = C:\NTDS
    DNS Server Fwd. IP = 208.67.222.222
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

# Disable Server Manager (Desktop Experience Only)
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -Value 1

# Disable IPv6
Get-NetAdapter -Name Ethernet0 | Set-NetAdapterBinding -ComponentID ms_tcpip6 -Enabled:$false

# Install packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module xActiveDirectory -Force
Install-Module xComputerManagement -Force
Install-Module xNetworking -Force
Install-Module xDnsServer -Force

# Setup FW rules to allow ICMP and SMB
Get-NetFirewallRule -Name *icmp4-erq*|Enable-NetFirewallRule
Get-NetFirewallRule -Name *fps-smb*|Enable-NetFirewallRule

# Start init
Set-Location C:\

configuration LabDomain {
    param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,

        [Parameter(Mandatory)]
        [pscredential]$domainCred
    )

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xDnsServer

    Node $AllNodes.Where{$_.Role -eq 'PrimaryDC'}.Nodename
    {

        # Setup DSC LCM settings
        LocalConfigurationManager
        {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
        }

        # Setup ADDS folders
        File ADFiles
        {
            DestinationPath = 'C:\NTDS'
            Type            = 'Directory'
            Ensure          = 'Present'
        }

        # Optional GUI tools
        WindowsFeature ADDSTools
        {
            Ensure = 'Present'
            Name   = 'RSAT-ADDS'
        }

        # IP Address
        xIPAddress Eth0IP
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = 'Ethernet0'
            IPAddress      = '192.168.100.200/24'
        }

        # DNS Settings
        xDNSServerAddress Eth0DNS
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = 'Ethernet0'
            Address        = '127.0.0.1', '208.67.222.222'
        }

        # Default Gateway
        xDefaultGatewayAddress Eth0Gateway
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = 'Ethernet0'
            Address        = '192.168.100.2'
        }

        # Setup PDC Computer Name
        xComputer ComputerName
        {
            Name      = 'pdc'
            DependsOn = '[xIPAddress]Eth0IP', '[xDNSServerAddress]Eth0DNS', '[xDefaultGatewayAddress]Eth0Gateway'
        }

        # Install ADDS
        WindowsFeature ADDSInstall
        {
            Ensure    = 'Present'
            Name      = 'AD-Domain-Services'
            DependsOn = '[xComputer]ComputerName'
        }

        # New domain
        xADDomain FirstDS
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DatabasePath                  = 'C:\NTDS'
            LogPath                       = 'C:\NTDS'
            DependsOn                     = '[WindowsFeature]ADDSInstall', '[File]ADFiles', '[xComputer]ComputerName'
        }

        # DNS Server Forwarding Address
        xDnsServerForwarder DnsFwdAddress
        {
            IsSingleInstance = 'Yes'
            IPAddresses      = '208.67.222.222'
            DependsOn        = '[xADDomain]FirstDS'
        }

    } # node

} # configuration LabDomain

# Configuration Data for AD
$ConfigData = @{
    AllNodes = @(
        @{
            Nodename                    = 'localhost'
            Role                        = 'PrimaryDC'
            DomainName                  = 'skynet.lab'
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
} # ConfigData

$splat = @{
    ConfigurationData         = $ConfigData
    SafemodeAdministratorCred = (Get-Credential -UserName '(Password Only)' -Message 'New Domain Safe Mode Administrator Password')
    DomainCred                = (Get-Credential -UserName lab\administrator -Message 'New Domain Admin Credential')
} # splat

LabDomain @splat

# Make sure that LCM is set to continue configuration after reboot
Set-DSCLocalConfigurationManager -Path .\LabDomain -Verbose

# Build the domain
Start-DscConfiguration -Wait -Force -Path .\LabDomain -Verbose

# complete