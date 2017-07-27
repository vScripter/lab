#!/bin/sh

# chmod u+x <file>.sh

: <<'END'
cd ~/GitHub/Lab/aws/ws16-lab/dc-01
echo '------------------------ [ws16-lab][Plan] Working on {dc-01}                ------------------------'
terraform plan

cd ~/GitHub/Lab/aws/ws16-lab/core-member-servers
echo '------------------------ [ws16-lab][Plan] Working on {Core-Member-Servers}  ------------------------'
terraform plan

cd ~/GitHub/Lab/aws/ws16-lab/member-servers
echo '------------------------ [ws16-lab][Plan] Working on {Member-Servers}       ------------------------'
terraform plan



cd dc-01
echo '------------------------ [ws16-lab][Apply] Working on {dc-01}                ------------------------'
terraform apply

cd ../core-member-servers
echo '------------------------ [ws16-lab][Apply] Working on {Core-Member-Servers}  ------------------------'
terraform apply

cd ../member-servers
echo '------------------------ [ws16-lab][Apply] Working on {Member-Servers}       ------------------------'
terraform apply
END


cd dc-01
echo '------------------------ [ws16-lab][DESTROY] {dc-01}               ------------------------'
terraform destroy -force

cd ../core-member-servers
echo '------------------------ [ws16-lab][DESTROY] {core-member-servers} ------------------------'
terraform destroy -force

cd ../member-servers
echo '------------------------ [ws16-lab][DESTROY] {member-servers}      ------------------------'
terraform destroy -force