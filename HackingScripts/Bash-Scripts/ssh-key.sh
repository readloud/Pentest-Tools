#!/bin/bash
clear
echo ""
echo ""

echo " # ############################################### #"
echo " # SSH Authentication for Single/Multi Machine(s)  #"
echo " # ----------------------------------------------- #"
echo " # Author : KING_Sabri                              #"
echo " # E-mail : sabri@security4arabs.com               #"
echo " # Created in : Sat Aug 8 2009  02:10 pm           #"
echo " # Last Modify: Tue Feb 15 2021  02:31 pm          #"
echo " # ############################################### #"

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

# Colored Texts 
echo -e $(tput sgr0) # Reset All Colors 
}

function message {
COLORIZING
if [ $WELCOME = 1 ]
then
echo  Hello $(logname)
echo ""
sleep 1
else
echo "no welcome msg for you :P"
fi
}

function INFORMATIONS {
COLORIZING

read -p " [+] Please Enter your Local Host User Name: " LUSER
read -p " [+] Please Enter your Remote Host User Name witch you need to Connect: " RUSER
echo -e $(tput setaf 1)
echo "#----------Notice:----------#"
echo " If you've list of IP's"
echo " Put the IP's in text file"
echo " Each IP in New Line!"
echo " No Empty Lines!"
echo " No Spaces!"
echo "#---------------------------#"
echo -e $(tput sgr0)
read -p " [+] Please Enter Remote Host's IP address or IP's List File path : " IPADDR
read -p " [+] Please Enter SSH's port used on Remote Host: " RPORT

# Review
clear
echo -e $(tput setaf 2)
echo	"=---------------------="
echo  	" Information Review.. "
echo	"=---------------------="
echo " [+] Local  Host User Name is: " $LUSER
echo " [+] Remote Host User Name is: " $RUSER
echo " [+] Remote Host(s) IP(s)  is: " $IPADDR
echo " [+] Remote Host SSH Port  is: " $RPORT
echo -e $(tput sgr0)
read -p " [!] Is this information correct [y or n]? " INFO

while [ $INFO = "n" ]
do
clear
echo	" "
echo	"=-----------------------------------="
echo  	" Please, Re-Enter Your Information.. "
echo	"=-----------------------------------="
echo	" "
read -p " [+] Pleas Enter your Local Host User Name: " LUSER
read -p " [+] Pleas Enter your Remote Host User Name witch you need to Connect: " RUSER
read -p " [+] Pleas Enter Remote Host's IP address or IP's List File path: " IPADDR
read -p " [+] Pleas Enter SSH's port used on Remote Host: " RPORT
# Review
clear
echo -e $(tput setaf 2)
echo	"=---------------------="
echo  	" Information Review.. "
echo	"=---------------------="
echo " [+] Local  Host User Name is: " $LUSER
echo " [+] Remote Host User Name is: " $RUSER
echo " [+] Remote Host(s) IP(s)  is: " $IPADDR
echo " [+] Remote Host User Port is: " $RPORT
echo -e $(tput sgr0)
read -p " [!] Is this information correct [y or n]? " INFO
done
sleep 1
}

function PKG {
COLORIZING
# Encryption
read -p " [+] Please Choose the Encryption Type [rsa , des] " ENC
ssh-keygen -t $ENC

# Check is it List Of IP's or Just One IP
if [ -f $IPADDR ]
then 

  for LIST in $(cat $IPADDR)
  do
	if [ $USER = 'root' ]; then
		scp -P $RPORT /root/.ssh/id_rsa.pub $RUSER@$LIST:.ssh/authorized_keys
#		exit 0

	else
		scp -P $RPORT /home/$LUSER/.ssh/id_rsa.pub $RUSER@$LIST:.ssh/authorized_keys
	fi
  done

else 
	if [ $USER = 'root' ]; then
		scp -P $RPORT /root/.ssh/id_rsa.pub $RUSER@$IPADDR:.ssh/authorized_keys
		exit 0

	else

		scp -P $RPORT /home/$LUSER/.ssh/id_rsa.pub $RUSER@$IPADDR:.ssh/authorized_keys
	fi
fi

}


INFORMATIONS
PKG

echo -e $(tput setaf 6)
echo " "
echo "--------------------------------------"
echo " Regards & Respect Good Bye $(logname)"
echo "--------------------------------------"
echo -e $(tput sgr0)
sleep 3
exit

