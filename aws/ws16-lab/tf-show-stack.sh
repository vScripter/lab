#!/bin/sh

# chmod u+x <file>.sh

cd dc-01
echo '------------------------ [ws16-lab][Show] {dc-01}               ------------------------'
terraform show

cd ../core-member-servers
echo '------------------------ [ws16-lab][Show] {core-member-servers} ------------------------'
terraform show

cd ../member-servers
echo '------------------------ [ws16-lab][Show] {member-servers}      ------------------------'
terraform show