#!/bin/bash 


COLORIZING()
{
# Text color variables
txtund=$(tput sgr 0 1)    # Underline
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtylw=$(tput setaf 3)    # Yellow
txtblu=$(tput setaf 4)    # Blue
txtpur=$(tput setaf 5)    # Purple
txtcyn=$(tput setaf 6)    # Cyan
txtwht=$(tput setaf 7)    # White
txtrst=$(tput sgr0)       # Text reset
}



BACKUP()
{
COLORIZING

echo $(tput setaf 3)$(tput bold)"Backup (VLAN's, DNS , Rules , Routes )..." ; echo -e $(tput sgr0)

#--> Create Backup's Folders
echo $(tput setaf 6)"[!] Prepare The Backup's Folder." ; echo -e $(tput sgr0)
mkdir -p `hostname`_Backup-`date +\%d-\%m-\%y`/{vlan,dns,rules,route}

#--> Backing-up 
echo $(tput setaf 6)"[!] Backup VLAN's." ; echo -e $(tput sgr0)
cp -a /etc/sysconfig/network-scripts/* `hostname`_Backup-`date +\%d-\%m-\%y`/vlan	# Ethernets&VLAN's

echo $(tput setaf 6)"[!] Backup IPtables' rules." ; echo -e $(tput sgr0)
/sbin/service iptables save > /dev/null 2>&1
cp -arf /etc/sysconfig/iptables  `hostname`_Backup-`date +\%d-\%m-\%y`/rules		# IPtables' Rules

echo $(tput setaf 6)"[!] Backup Routing table." ; echo -e $(tput sgr0)
route -n > `hostname`_Backup-`date +\%d-\%m-\%y`/route/route.txt
cp -arf /etc/sysconfig/network `hostname`_Backup-`date +\%d-\%m-\%y`/route/		# Routing Table

echo $(tput setaf 6)"[!] Backup DNS Configurations." ; echo -e $(tput sgr0)
cp -arf /etc/hosts  `hostname`_Backup-`date +\%d-\%m-\%y`/dns				# DNS Configurations (hosts)
cp -arf /etc/resolv.conf  `hostname`_Backup-`date +\%d-\%m-\%y`/dns			# DNS Configurations (resolve.conf)

echo $(tput setaf 6)"[!] Archiving, Please waite!..." ; echo -e $(tput sgr0)
tar -czf `hostname`_Backup-`date +\%d-\%m-\%y`.tar.gz `hostname`_Backup-`date +\%d-\%m-\%y`/
sleep 3
echo $(tput setaf 2)$(tput bold)"Backup has been Done!!" ; echo -e $(tput sgr0)
}


ROUTING()
{
COLORIZING

#ip route flush # Flush Exist Routing Table


echo $(tput setaf 7)"[!] Backup exist routing table" ; echo -e $(tput sgr0)
cd `hostname`_Backup-`date +\%d-\%m-\%y`/route
/sbin/route -n > route-exist.txt   # backup the current route table

#--> Comparing routing tables (exist & backuped)
echo $(tput setaf 7)"[!] Comparing routing tables (exist with backup) Files" ; echo -e $(tput sgr0)
DIFF=`diff route-exist.txt route.txt`
if [ -z "$DIFF" ]
  then 
    echo $(tput bold)$(tput setaf 2)"The routes Are Correct!"$(tput sgr0)
    echo $(tput bold)$(tput setaf 2)"No need to Edit routing table"$(tput sgr0)

else
   echo $(tput setaf 3)"[!] Routing Tables are not Identical!!" ; echo -e $(tput sgr0) 
sleep 2
# Count Lines to know the number of routes
   lines=`wc -l route.txt | cut -d " " -f1`
    for NUM in $(seq 3 $lines)
     do

      DEST=`sed -n $NUM'p' route.txt | cut -d " " -f1`		# Destiniation of route n
      GW=`sed -n $NUM'p' route.txt | cut -d " " -f5`		# Gateway
      NMASK=`sed -n $NUM'p' route.txt | cut -d " " -f14`	# Gateway Netmask
      ETH=`sed -n $NUM'p' route.txt | cut -c73-80`		# Ethernet (Interface)

# Find The Default Gateway
      DGW=`grep UG route.txt | cut -c49-50`
      if [[ "$DGW" == UG ]]
	then
	  ETHGW=`grep UG route.txt | cut -c73-80`
      fi
    done

# Restore The Routing Table from "routes.txt" file

echo -e $(tput setaf 1)$(tput bold)
read -p "Attention!! The EXIST routing table will be Overwritten Regarding The Backup [y/n] " ROUTE
echo -e $(tput sgr0)
     if [[ "$ROUTE" == y ]]
       then
         DEFGW=`grep UG route.txt | sed -n $NUM'p' route.txt | cut -c17-31` # find Default Gateway IP address
	 DEFMASK=`grep UG route.txt | sed -n 16'p' route.txt | cut -c33-48` # find Default Gateway Netmask
	 /sbin/route add default gw $DEFGW netmask $DEFMASK		   # Add The Default Gateway
     fi
fi

echo -e $(tput setaf 6)
echo "[+] FYI, Please Notice the examples for routing:-"
echo " To Add route: ip route add 192.168.55.0/24 via 192.168.1.254 dev eth1  "
echo " To Delete route: ip route del 192.168.55.0/24 via 192.168.1.254 dev eth1  "
echo " To Add Default Gateway: route add default gw 192.168.1.1 netmask 255.255.255.0"
echo " To Delete Default Gateway: route del default gw 192.168.1.1 netmask 255.255.255.0"
echo -e $(tput sgr0)
}

BACKUP

