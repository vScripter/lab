#!/bin/sh

# chmod u+x <file>.sh

cd dc-01
echo '------------------------ [ws16-lab][Plan] Working on {dc-01}                ------------------------'
terraform plan -var 'admin_password=VMware1!'

cd ../core-member-servers
echo '------------------------ [ws16-lab][Plan] Working on {Core-Member-Servers}  ------------------------'
terraform plan -var 'admin_password=VMware1!'

cd ../member-servers
echo '------------------------ [ws16-lab][Plan] Working on {Member-Servers}       ------------------------'
terraform plan -var 'admin_password=VMware1!'