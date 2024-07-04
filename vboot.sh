#!/bin/bash
#Victim

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>log.out 2>&1

SETUPCOMPLETE="/var/log/setupcomplete.log"
if [[ ! -f $SETUPCOMPLETE ]]; then
   #FirstRun
   sudo apt-get remove --purge man-db -y
   sudo apt-get update && sudo apt-get install netcat -y
   sudo curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
   sudo bash add-google-cloud-ops-agent-repo.sh --also-install
   sudo useradd -p "$(openssl passwd -6 gplatadmintestingpassword)" userattack
   sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
   sudo service sshd restart

echo 'logging:
  receivers:
    authlog:
      type: files
      include_paths:
      - /var/log/auth.log
  service:
    pipelines:
      default_pipeline:
        receivers: [authlog]
metrics:
  receivers:
    hostmetrics:
      type: hostmetrics
      collection_interval: 60s
  processors:
    metrics_filter:
      type: exclude_metrics
      metrics_pattern: []
  service:
    pipelines:
      default_pipeline:
        receivers: [hostmetrics]
        processors: [metrics_filter]' >> /etc/google-cloud-ops-agent/config.yaml
    sudo systemctl restart google-cloud-ops-agent"*"
   #the next line creates an empty file so it won't run the next boot
   touch "$SETUPCOMPLETE"
   shutdown
   
else
   echo "Second Run"
   sleep 900

   shutdown
fi
