# Windows Server 2016 Lab

## Prerequisites
* This lab requires that you have remote state configured. You can refer to the lab root, in `lab\global\state` which has the configuration used for remote state.
* This lab requires that you have already applied the global VPC configuration located in `lab\aws\global\vpc`

## Deployment

By default, this lab will deploy the following:
* 1 x Server 2016 Server (Full), deployed with the name `dc-01` (meant to be converted to a Domain Controller)
* 1 x Server 2016 Server (Full), deployed with the name `ws16b-[0..x]` (the number will auto-increment if you choose to deploy more than one )
* 1 x Server 2016 Core Server, deployed with the name `ws16c-[0..x]` (the number will auto-increment if you choose to deploy more than one )

If desired, you can use the `.ps1` scripts in each of the designated folders to convert the Domain Controller into a PDC, and the member server(s) to domain members. The scripts leverage PowerShell DSC (Desired State Configuration) and will fully configure the PDC and join any Member Server(s) to the domain, if executed.

You should be able to SSH and RDP directly to anything deployed and those addresses will be part of the output when executing terraform.

## Environment Information
| Key | Value
|:-----|:-----
| Domain Name | `cloud.lab`
| Local User Account | `Administrator` / `VMware1!`
| Domain User Account | `CLOUD\Administrator` / `VMware1!`

### Execution

There are preconfigured `.sh` scripts that will execute the desired terraform action on the entire stack (apply/plan/destroy/output/show). I'm working on getting `terragrunt` working, but these scripts are what I'm using, for now.

If you are in a Windows environment, assuming that the `terraform.exe` binary path is in your environmental PATH (`$ENV:Path` in PowerShell), you can rename all of the files with a `.ps1` file extension and they should work just the same.