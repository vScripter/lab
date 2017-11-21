# PowerShell DSC Lab

These scripts contain a DSC configuration that is purpose-built to be run on individual servers.

They were written with a use-case of being able to quickly change the personality of a newly deployed Windows Server.

## Prerequisites
- Windows Server .ISO/Image
- Internet Access _(Guests need access to pull DSC Resource Modules from the PowerShell Gallery)_

## Execution
- Copy/Paste the contents of the script into the PowerShell Console on the designated server
- The DSC config is written to wait for Domain availability for Member Servers, which supports deploying all servers at the same time (no need to wait for the DC to be available before processing with deployment of the Member Servers)
- Execution usually takes about 10-15 minutes to go from Zero-to-Domain

> Note: The Member Servers and the Domain Controller cannot have the same SID. If deploying from the same image, using snapshots, etc., ensure that you at least run `sysprep` on either the server designated to be the Domain Controller, or on all Member Servers.

### Platform Support

Testing has been done on these versions of Windows:
- Server 2016 (Desktop Experience)
- Server 2016