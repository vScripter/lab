# PowerShell DSC Lab

These scripts contain a DSC configuration that is purpose-built to be run on individual servers.

They were written with a use-case of being able to quickly change the personality of a newly deployed Windows Server.

## Execution
- Copy/Paste the contents of the script into the PowerShell Console on the designated server

> Note: The Member Servers and the Domain Controller cannot have the same SID. If deploying from the same image, using snapshots, etc., ensure that you at least run `sysprep` on either the server designated to be the Domain Controller, or on all Member Servers.