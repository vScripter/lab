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
    Import-DSCResource -ModuleName xComputerManagement
    Import-DSCResource -ModuleName xActiveDirectory

    Node $AllNodes.Where{$_.Role -eq "Member-Server"}.Nodename {

        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        xComputer DomainMember {
            Name = $node.NodeName
            DomainName = $node.DomainName
            Credential = $DomainCredential
        }

        xWaitForADDomain WaitForCloudDomain
        {
            DomainName = 'cloud.lab'
            RetryIntervalSev = 120
            RetryCount = 5
            RebootRetryCount = 3
            DependsOn = '[xComputer]DomainMember'
        }

    } # Node

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

# Complete