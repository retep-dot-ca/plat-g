#!/bin/bash
#Victim

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>log.out 2>&1

SETUPCOMPLETE="/var/log/setupcomplete.log"
if [[ ! -f $SETUPCOMPLETE ]]; then
   #FirstRun
   
   #the next line creates an empty file so it won't run the next boot
   touch "$SETUPCOMPLETE"

else
   echo "Second Run"

fi
