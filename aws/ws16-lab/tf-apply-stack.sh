#!/bin/sh

# chmod u+x <file>.sh

cd dc-01
echo '------------------------ [ws16-lab][Apply] Working on {dc-01}                ------------------------'
terraform apply -var 'admin_password=VMware1!'

cd ../core-member-servers
echo '------------------------ [ws16-lab][Apply] Working on {Core-Member-Servers}  ------------------------'
terraform apply -var 'admin_password=VMware1!'

cd ../member-servers
echo '------------------------ [ws16-lab][Apply] Working on {Member-Servers}       ------------------------'
terraform apply -var 'admin_password=VMware1!'