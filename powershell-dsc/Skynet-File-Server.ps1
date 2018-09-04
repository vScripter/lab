Set-Location C:\

configuration FileShare {

param(
    [parameter(Mandatory = $false)]
    [PSCredential]$DomainCredential
)

Import-DscResource –ModuleName PSDesiredStateConfiguration
Import-DSCResource -ModuleName xSmbShare
Import-DscResource -ModuleName cNtfsAccessControl

Node $AllNodes.Where{$_.Role -eq "File-Server"}.Nodename {


        File RootShareDirectory
        {
            Ensure = "Present"
            Type = 'Directory'
            DestinationPath = 'C:\RootShare'
        }

        File AccountingDirectory
        {
            Ensure = "Present"
            Type = 'Directory'
            DestinationPath = 'C:\RootShare\Accounting'
        }

        File FinanceDirectory
        {
            Ensure = "Present"
            Type = 'Directory'
            DestinationPath = 'C:\RootShare\Finance'
        }

        cNtfsPermissionEntry AccountingACE1
        {
            Ensure = 'Present'
            Path = 'C:\RootShare\Accounting'
            Principal = 'CLOUD\User1'
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = 'Allow'
                    FileSystemRights = 'Modify'
                    Inheritance = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $true
                }
            )
            DependsOn = @(
                '[File]AccountingDirectory',
                '[cNtfsPermissionsInheritance]AccountingNoInheritance',
                '[cNtfsPermissionEntry]RootShareACE1'
                )
        }

        cNtfsPermissionsInheritance AccountingNoInheritance
        {
            Path = 'C:\RootShare\Accounting'
            Enabled = $false
            PreserveInherited = $true
            DependsOn = '[File]AccountingDirectory'
        }

        cNtfsPermissionEntry RootShareACE1
        {
            Ensure = 'Present'
            Path = 'C:\RootShare'
            Principal = 'CLOUD\DL-Share-Access'
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = 'Allow'
                    FileSystemRights = 'Modify'
                    Inheritance = 'ThisFolderOnly'
                    NoPropagateInherit = $true
                }
            )
            DependsOn = @('[File]RootShareDirectory')
        }

        xSmbShare RootShare
        {
            Ensure       = "Present"
            Name         = "Accounting"
            Path         = "C:\RootShare"
            FullAccess   = "Cloud\Administrator"
            ChangeAccess = @("Cloud\DL-Share-Access")
            Description  = "Root Share"
            DependsOn    = "[File]RootShareDirectory"
        }
    }

} # configuration

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            Role = "File-Server"
        }
    )
}


FileShare -ConfigurationData $ConfigData

# Make sure that LCM is set to continue configuration after reboot
#Set-DSCLocalConfigurationManager -Path .\FileShare –Verbose

# Build the domain
Start-DscConfiguration -Wait -Force -Path .\FileShare -Verbose

<# LEGACY CODE

#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Install-Module xComputerManagement -Force

Get-DnsClientServerAddress -InterfaceAlias 'Ethernet 2' -AddressFamily IPv4 | Set-DnsClientServerAddress -ServerAddresses @('10.10.1.100')

Clear-DNSClientCache

Set-Location C:\

configuration DomainMember {

param(
    [parameter(Mandatory = $true)]
    [PSCredential]$DomainCredential
)

Import-DscResource –ModuleName PSDesiredStateConfiguration
Import-DSCResource -ModuleName File
Import-DSCResource -ModuleName xComputerManagement
Import-DSCResource -ModuleName xSmbShare

Node $AllNodes.Where{$_.Role -eq "Member-Server"}.Nodename {

        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        File RootShareDirectory
        {
            Ensure = "Present"
            Type = 'Directory'
            DestinationPath = 'C:\RootShare'
        }

        xComputer DomainMember
        {
            Name       = $node.NodeName
            DomainName = $node.DomainName
            Credential = $DomainCredential
        }

        xSmbShare RootShare
        {
            Ensure       = "Present"
            Name         = "Accounting"
            Path         = "C:\RootShare"
            ChangeAccess = @("Cloud\User1","Cloud\User2")
            Description  = "Root Share"
            DependsOn    = "[File]RootShareDirectory"
        }
}


} # configuration

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            Role = "Member-Server"
            DomainName = "cloud.lab"
            PsDSCAllowplaintextpassword = $true
        }
    )
}


DomainMember -ConfigurationData $ConfigData -DomainCredential (Get-Credential -Message 'Enter Cloud Admin Domain Credential' -Username 'cloud\administrator')

# Make sure that LCM is set to continue configuration after reboot
Set-DSCLocalConfigurationManager -Path .\DomainMember –Verbose

# Build the domain
Start-DscConfiguration -Wait -Force -Path .\DomainMember -Verbose

Write-Output 'Config Applied'


#>