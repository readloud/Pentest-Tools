bin/bash

echo "                                          # ############################################### #"
echo "                                          #                                                 #"
echo "                                          #      This Script for configureing DNS Server    #"
echo "                                          # ----------------------------------------------- #"
echo "                                          # Author : Eng.Sabri                              #"
echo "                                          # Comepany : Innovative Application Co. Tdl.      #"
echo "                                          # Created in : Sun May 31 12:11:00 AST 2009       #"
echo "                                          # Last Modify: Wed Jun  3 08:49:20 AST 2009       #"
echo "                                          # ############################################### #"


# Variable Section
WELCOME="1"
CHOICES="1 2 3 4 5"

# Function Section
function menu {
  clear
  clear
  echo Hello $(logname)
  echo "########################### DNS Configurations ##############################"
  echo "###                     What would you like to do ?                       ###"
  echo "###    1) Add Hostname(FQDN) & IP address                          ###"
  echo "###    2) Install DNS server                                              ###"
  echo "###    3) Add New Zone to DNS server                              ###"
  echo "###    4) Edit DNS configureation File Maniualy                          ###"
  echo "###    5) Exits This Script                                               ###"
  echo "#################### Innovative Applications Co. Tdl. #######################"
  echo " Attention!: This script For Red Hat Based distributions Only. "
  echo " "
  echo " "
}

function message {
if [ $WELCOME = 1 ]
    then
echo  Hello $(logname)
echo ""
sleep 1
else
echo "no welcome msg for you :P"
fi
}

function IPandHOST {
  clear
  read -p "Pleas Enter Host Name(FQDN):   " HOST
  read -p "Pleas Enter The Interface Name (ex. eth0,eth1,etc...):   " INTERFACE
  echo YOUR INTERFACE IS.. $INTERFACE
  read -p "Pleas Enter Server's IP address:   " IPADDR
  #echo "DEVICE=$INTERFACE" > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  #echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  #echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  #ifconfig $INTERFACE | grep HWaddr | awk '{print $4"="$5}' >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  #echo "IPADDR=$IPADDR" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  read -p "Pleas Enter Server's Netmask address:   "  NETMASK
  #echo "NETMASK=$NETMASK" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  read -p "Pleas Enter Gateway's address:   " GATEWAY
  #echo "GATEWAY=$GATEWAY" >> /etc/sysconfig/network
 
  hostname $HOST
 cat << EOF > /etc/sysconfig/network  
  NETWORKING=yes
  NETWORKING_IPV6=no
  HOSTNAME=$HOST
EOF
  echo "Your FQDN is ... $HOST"  
  echo "DEVICE=$INTERFACE" > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo $(ifconfig $INTERFACE | grep HWaddr | awk '{print $4"="$5}') >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "IPADDR=$IPADDR" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "NETMASK=$NETMASK" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
  echo "GATEWAY=$GATEWAY" >> /etc/sysconfig/network
#   echo $(IPADDR  "               " HOST && echo "           " HOST  awk '{print $1}'| cut -d "." -f1 ") >> /etc/hosts
  ALIAS=`echo $HOST | cut -d "." -f 1`
  echo "$IPADDR\t\t $HOST\t\t $ALIAS" >> /etc/hosts

  ifconfig $INTERFACE $IPADDR
  ifconfig $INTERFACE netmask $NETMASK
  service network restart
  echo "$INTERFACE's Informstions ..."
  echo "IP address:  "$IPADDR
  echo "Netmask:  "$NETMASK
  echo "Gateway:  "$GATEWAY
  sleep 3
  echo Thank you Sir ..
  sleep 1
}

function INSTALL {
  clear
  yum -y install bind
  mv /etc/named.conf /etc/named.conf.orig
  touch /etc/named.conf

cat << EOF > /etc/named.conf
 #################################################### OPTIONS #################################################

      options
      {
        // Those options should be used carefully because they disable port
        // randomization
         query-source    port 53;    
        // query-source-v6 port 53;

        // Put files that named is allowed to write in the data/ directory:
        directory "/var/named"; // the default
        dump-file         "data/cache_dump.db";
        statistics-file     "data/named_stats.txt";
        memstatistics-file     "data/named_mem_stats.txt";
      auth-nxdomain no ;  //
    };

    #################################################### ZONE #################################################
EOF
  service named restart
  sleep 3
  echo Installation has been finished Successfully ..
  echo Thank you Sir ..
  sleep 2

}

function CZONE {
  clear
  read -p  "Pleas Enter Zone Name (FQDN):   " ZONENAME
  read -p  "Pleas Enter IP address Of Zone:   " ZIPADDR
  read -p  "Pleas Enter One More Name for Server (ex. ns,server,etc.):   " OTHERNS
  touch /var/named/$ZONENAME.zone
cat << EOF >>  /var/named/$ZONENAME.zone
\$TTL    86400
@               IN        SOA         $ZONENAME  root (
                                                           42              ; serial (d. adams)
                                                           3H              ; refresh
                                                           15M             ; retry
                                                           1W              ; expiry
                                                           1D )            ; minimum


                          IN       NS           $ZONENAME.
$ZONENAME.                IN       A            $ZIPADDR
$OTHERNS                  IN       A            $ZIPADDR

EOF


############################ Revers Of Zone ################################

cat << EOF > /var/named/lookup.rr.zone
\$TTL    86400
@               IN      SOA     $ZONENAME.      root (
                                                         42              ; serial (d. dams)
                                                         3H              ; refresh
                                                         15M             ; retry
                                                         1W              ; expiry
                                                         1D )            ; minimum


                   IN       NS            $ZONENAME.
`ifconfig $INTERFACE | grep "inet addr"| awk '{print $2}' | cut -d  "." -f4 `                       IN       PTR        $ZONENAME.
EOF


echo "####################################"
echo "###     named.conf Editing...    ###"
echo "####################################"

#################################################### ZONES in named.conf #####################################################
cat << EOF >> /etc/named.conf
zone  "$ZONENAME" IN
    {
         type master ;
         file "$ZONENAME.zone";
 #        allow-query   { any ; } ;
 #        allow-update  { none ; } ;
     };

EOF

################################################## Revers ZONE in named.conf #############################################################

 read -p "Pleas Enter first three Octet from right to lift    " REVERSE
cat << EOF >> /etc/named.conf
  zone "$REVERSE.in-addr.arpa" IN
        {
                type master ;
            file "lookup.rr.zone" ;
            //allow-query { any ; };
            //allow-update { none ;  } ;
        };
EOF

}

function EDITNAMED {
  clear
  nano /etc/named.conf
}


###  Main Script Section ###
clear
        message
    menu    
select choix in $CHOICES; do                    
    if [ "$choix" = "1" ]; then
    IPandHOST
    menu            
    elif [ "$choix" = "2" ]; then
    INSTALL
        menu
        elif [ "$choix" = "3" ]; then
    CZONE
        menu
        elif [ "$choix" = "4" ]; then
        EDITNAMED
        menu
        elif [ "$choix" = "5" ]; then
        clear
    echo " "
    echo "--------------------------------------"
    echo " Script Terminated Good Bye $(logname)"
    echo "--------------------------------------"
        exit        
    else
    clear
    menu
    echo " "
    echo " "        
    echo " "        
    echo " "        
    echo "################################################################"
    echo "###         Please Try again wrong number   !!!              ###"
    echo "################################################################"
        sleep 2
    clear
    menu
    fi
done 
