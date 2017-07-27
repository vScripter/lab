Set-Location C:\

configuration CloudLabDomain
{
   param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred
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
            DependsOn                     = "[WindowsFeature]ADDSInstall","[File]ADFiles"
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

Write-Output 'Config Applied'