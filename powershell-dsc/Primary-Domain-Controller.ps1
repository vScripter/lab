<#
.SYNOPSIS
    Sample DSC Configuration for standing up a Domain controller.
.DESCRIPTION
    Sample DSC Configuration for standing up a Domain controller.

    Standard Config
    ---------------------------
    IPv6           = Disabled
    ICMP FW Rules  = Allow
    SMB FW Rules   = Allow
    HostName       = PDC
    Domain Name    = lab.local
    NTDS File Path = C: \NTDS
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

    Node $AllNodes.Where{$_.Role -eq 'PrimaryDC'}.Nodename
    {

        # Setup DSC LCM settings
        LocalConfigurationManager
        {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
        }

        # Setup PDC Computer Name
        xComputer ComputerName
        {
            Name = 'pdc'
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

    } # node

} # configuration LabDomain

# Configuration Data for AD
$ConfigData = @{
    AllNodes = @(
        @{
            Nodename                    = 'localhost'
            Role                        = 'PrimaryDC'
            DomainName                  = 'lab.local'
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