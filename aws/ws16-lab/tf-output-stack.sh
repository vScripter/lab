#!/bin/sh

# chmod u+x <file>.sh

cd dc-01
echo '------------------------ [ws16-lab][Output] {dc-01}               ------------------------'
terraform output

cd ../core-member-servers
echo '------------------------ [ws16-lab][Output] {core-member-servers} ------------------------'
terraform output

cd ../member-servers
echo '------------------------ [ws16-lab][Output] {member-servers}      ------------------------'
terraform output