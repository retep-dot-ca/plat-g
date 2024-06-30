#!/bin/bash
#Victim

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>log.out 2>&1

SETUPCOMPLETE="/var/log/setupcomplete.log"
if [[ ! -f $SETUPCOMPLETE ]]; then
   #FirstRun
   sudo apt-get update && sudo apt-get install netcat -y
   sudo adduser userattack
   #sudo echo userattack:gplatadmintestingpassword | chpasswd
   #sudo echo "AllowUsers userattack@10.1.1.2" >> /etc/ssh/sshd_config
   #sudo touch /etc/ssh/sshd_config.d/10-password-login-for-userattack.conf
   #sudo echo "Match User" >> /etc/ssh/sshd_config.d/10-password-login-for-userattack.conf
   #sudo echo " PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/10-password-login-for-userattack.conf

   
   #the next line creates an empty file so it won't run the next boot
   touch "$SETUPCOMPLETE"

else
   echo "Second Run"
   #netcat -lp 3389 </dev/null >/dev/null 2>&1
   #netcat -lp 21 </dev/null >/dev/null 2>&1

   #sleep 360

   shutdown
fi
