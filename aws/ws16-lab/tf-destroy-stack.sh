#!/bin/sh

# chmod u+x <file>.sh

cd dc-01
echo '------------------------ [ws16-lab][DESTROY] {dc-01}               ------------------------'
terraform destroy -force -var 'admin_password=foo'

cd ../core-member-servers
echo '------------------------ [ws16-lab][DESTROY] {core-member-servers} ------------------------'
terraform destroy -force -var 'admin_password=foo'

cd ../member-servers
echo '------------------------ [ws16-lab][DESTROY] {member-servers}      ------------------------'
terraform destroy -force -var 'admin_password=foo'