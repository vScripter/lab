# Windows Server 2016 Lab

## Prerequisites
* This lab requires that you have remote state configured. You can refer to the lab root, in `lab\global\state` which has the configuration used for remote state.
* This lab requires that you have already applied the global VPC configuration located in `lab\aws\global\vpc`

## Deployment

By default, this lab will deploy the following:
* 1 x Server 2016 Server (Full), which will be a domain controller
* 1 x Server 2016 Server (Full)
* 1 x Server 2016 Core Server

If desired, you can use the `.ps1` scripts in each of the designated folders to convert the Domain Controller into a PDC, and the member server(s) to domain members. The scripts leverage PowerShell DSC (Desired State Configuration) and will fully configure the PDC and join any Member Server(s) to the domain, if executed.

### Execution

There are preconfigured `.sh` scripts that will execute the desired terraform action on the entire stack (apply/plan/destroy/output/show). I'm working on getting `terragrunt` working, but these scripts are what I'm using, for now.