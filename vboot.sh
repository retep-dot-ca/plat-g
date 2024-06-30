#!/bin/bash
#Victim

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>log.out 2>&1

SETUPCOMPLETE="/var/log/setupcomplete.log"
if [[ ! -f $SETUPCOMPLETE ]]; then
   #FirstRun
   sudo apt-get update && sudo apt-get install netcat -y
   sudo apt-get remove --purge man-db -y
   curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
   sudo bash add-google-cloud-ops-agent-repo.sh --also-install
   sudo useradd -p "$(openssl passwd -6 gplatadmintestingpassword)" userattack
   sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
   sudo service sshd restart
   
   #the next line creates an empty file so it won't run the next boot
   touch "$SETUPCOMPLETE"
   shutdown
   
else
   echo "Second Run"
   netcat -lp 3389 &
   netcat -lp 21 &

   sleep 360

   shutdown
fi
