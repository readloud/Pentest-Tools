#!/bin/bash

#some variables
DEFAULT_ROUTE=$(ip route show default | awk '/default/ {print $3}')
IFACE=$(ip route show | awk '(NR == 2) {print $3}')
JAVA_VERSION=`java -version 2>&1 |awk 'NR==1{ gsub(/"/,""); print $3 }'`
MYIP=$(ip route show | awk '(NR == 2) {print $9}')
######## Update Kali
function updatekali {
clear
echo -e "
\033[31m#######################################################\033[m
                Let's Update Kali
\033[31m#######################################################\033[m"
select menusel in "Update sources.list (Included kali sana repository for installing more package)" "Update Kali Sana 2.0 to Kali 2016.2" "Update and Clean Kali" "Back to Main"; do
case $menusel in
        "Update sources.list (Included kali sana repository for installing more package)")
                
		echo -e "\033[31m====== Adding new sources list and updating ======\033[m"
		rm /etc/apt/sources.list
		echo "" >> /etc/apt/sources.list
		echo 'deb http://http.kali.org/kali kali-rolling main non-free contrib' >> /etc/apt/sources.list
		echo 'deb-src http://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list
		echo 'deb http://old.kali.org/kali sana main non-free contrib' >> /etc/apt/sources.list
		apt-get update
		pause
		clear ;;	
	"Update Kali Sana 2.0 to Kali 2016.2")
		clear
		echo -e "\033[32mUpdating Kali Sana to Kali Linux 2016.2\033[m"
		rm /etc/apt/sources.list
		echo "" >> /etc/apt/sources.list
		echo 'deb http://http.kali.org/kali kali-rolling main non-free contrib' >> /etc/apt/sources.list
		echo 'deb-src http://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list
		#apt-get update && apt-get -y dist-upgrade
		apt-get update && apt-get -y upgrade 
		echo -e "\033[32mDone updating kali. You need to reboot your Kali Linux system\033[m"
		pause
		clear ;;
	
	"Update and Clean Kali")
		clear
		echo -e "\033[32mUpdating and Cleaning Kali\033[m"
		apt-get update && apt-get -y dist-upgrade && apt-get autoremove -y && apt-get -y autoclean
		echo -e "\033[32mDone updating and cleaning kali\033[m" ;;
		
	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		updatekali ;;

esac

break

done
}
######### Install WebApp Hacking Lab
function WebAppLab {
clear
echo -e "
\033[31m#######################################################\033[m
                Install WebApp Hacking Lab
\033[31m#######################################################\033[m"

select menusel in "Installing bWAPP" "Installing DVWA" "Install All" "Back to Main"; do
case $menusel in 
	"Installing bWAPP")
		installbWAPP
		pause 
		WebAppLab ;;
	"Installing DVWA")
		installdvwa
		pause
		WebAppLab ;;
	"Install All")
		installbWAPP
		installdvwa
		pause
		WebAppLab ;;
	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		WebAppLab ;;
	
		
esac

break

done
}
######## Install Dirs3arch
function installDirs3arch {
	echo -e "\e[1;31mThis option will install dirs3arch!\e[0m"
	echo -e "\e[1;31mHTTP(S) directory/file brute forcer\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing dirs3arch ======\033[m"
				sleep 2
				git clone https://github.com/maurosoria/dirs3arch.git /opt/intelligence-gathering/WebApp/dirs3arch-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install dvwa
function installdvwa {
	echo -e "\e[1;31mThis option will install dvwa!\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing dvwa ======\033[m"
				sleep 2
				chmod +x installing-dvwa.sh
				./installing-dvwa.sh
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install bwapp
function installbWAPP {
	echo -e "\e[1;31mThis option will install bwapp!\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing bwapp ======\033[m"
				sleep 2
				chmod +x installing-bwapp.sh
				./installing-bwapp.sh
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
#### Bleachbit Virtualbox
function installvirtualbox {
	echo -e "\e[1;31mThis option will install Virtualbox and fix "Unable to connect USB devices to a VirtualBox guest from Debian"!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Virtualbox now!\e[0m"
		apt-get install -y virtualbox-guest-x11 virtualbox virtualbox-ext-pack linux-headers*
		usermod -a -G vboxusers ddos
		echo -e "\e[32m[-] Done Installing Virtualbox!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi	
}
#### Bleachbit Installation
function installbleachbit {
	echo -e "\e[1;31mThis option will install Bleachbit!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Bleachbit now!\e[0m"
		apt-get -y install bleachbit 
		echo -e "\e[32m[-] Done Installing Bleachbit!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi	
}
#### arc theme Installation
function installarctheme {
	echo -e "\e[1;31mThis option will install arc theme & arc icon!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing arc theme & arc icon now!\e[0m"
		apt-get -y install autoconf automake pkg-config libgtk-3-dev git
		git clone https://github.com/horst3180/arc-theme --depth 1 && cd arc-theme
		./autogen.sh --prefix=/usr
		sudo make install
		cd ..
		rm -rf arc-theme
		git clone https://github.com/horst3180/arc-icon-theme --depth 1 && cd arc-icon-theme
		./autogen.sh --prefix=/usr
		sudo make install
		cd ..
		rm  -rf arc-icon-theme 
		echo -e "\e[32m[-] Done Installing arc theme!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi	
}
#### GoldenDict Installation
function installGoldendict {
	echo -e "\e[1;31mThis option will install GoldenDict!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing GoldenDict now!\e[0m"
		apt-get -y install goldendict 
		echo -e "\e[32m[-] Done Installing goldendict!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi	
}
#### Metasploit Installation
function installmetasploitframework {
	echo -e "\e[1;31mThis option will install metasploit framework on Ubuntu/Mint!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Metasploit now!\e[0m"
		curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
  		chmod 755 msfinstall
  		./msfinstall 
		echo -e "\e[32m[-] Done Installing Metasploit!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi	
}
######## Install Flash
function installflash {
	echo "This will install Flash. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Flash now!\e[0m"
		apt-get -y install flashplugin-nonfree
		update-flashplugin-nonfree --install
		echo -e "\e[32m[-] Done Installing Flash!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}
######## Install RecordMyDesktop
function installrecordmydesktop {
	echo "This will install RecordMyDesktop. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing RecordMyDesktop now!\e[0m"
		apt-get -y install gtk-recordmydesktop
		echo -e "\e[32m[-] Done Installing RecordMyDesktop!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}
######## Install Pinta
function installpinta {
	echo "This will install Pinta (image editor). Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Pinta now!\e[0m"
		apt-get -y install pinta
		echo -e "\e[32m[-] Done Installing Pinta!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}
######## Install GnomeTweakTool
function installgnometweaktool {
	echo "This will install Gnome Tweak Tools. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Gnome Tweak Tool now!\e[0m"
		apt-get -y install gnome-tweak-tool
		echo -e "\e[32m[-] Done Installing Gnome Tweak Tool!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}
######## Install ibus
function installibus {
	echo "This will install ibus. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing ibus now!\e[0m"
		apt-get -y install ibus && apt-get -y install ibus-unikey
		echo -e "\e[32m[-] Done Installing ibus!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}
######## Install libreoffice
function installlibreoffice {
	echo "This will install libreoffice. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing libreoffice now!\e[0m"
		apt-get -y install libreoffice
		echo -e "\e[32m[-] Done Installing libreoffice!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}
######## Install knotes
function installknotes {
	echo "This will install knotes. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing knotes now!\e[0m"
		apt-get -y install knotes
		echo -e "\e[32m[-] Done Installing knotes!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}
######## Install Veil-Framework
function installveil {
if [ ! -f /opt/BypassAV/Veil-Evasion/Veil-Evasion.py ]; then
	echo -e "\e[1;31mThis option will install Veil-Evasion!\e[0m"
	echo -e "\e[1;31mHow to use Veil-Evasion\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=H_0MPjSF5L0\e[0m"
	echo -e "\e[1;31mHow to change Veil-Evasion icon\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=WeM0c0s-vQI\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Veil-Evasion ======\033[m"
				sleep 2
				git clone https://github.com/Veil-Framework/Veil-Evasion.git /opt/BypassAV/Veil-Evasion/
				cd /opt/BypassAV/Veil-Evasion/setup
				./setup.sh -s
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] Veil-Evasion already installed !\e[0m"
	fi
}
######## Install VPN-BOOK
function installvpnbook {
if [ ! -f /root/Desktop/vpnbook.sh ]; then
	echo -e "\e[1;31mThis option will install VPN-BOOK!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing VPN-BOOK ======\033[m"
				sleep 2
				cd /root/Desktop
				wget https://github.com/Top-Hat-Sec/thsosrtl/blob/master/VeePeeNee/VeePeeNee.sh
				mv VeePeeNee.sh vpnbook.sh
				chmod a+x vpnbook.sh
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] VPN-BOOK already installed !\e[0m"
	fi
}
######### Install Google Chrome
function installgooglechrome {
	echo -e "\e[1;33mThis option will install google chrome.\e[0m"
	echo "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
			read -p "Are you using a 32bit or 64bit operating system [ENTER: 32 or 64]? " operatingsys
			if [ "$operatingsys" == "32" ]; then 
				echo -e "\e[1;33m[+] Downloading Google Chrome for Debian 32bit\e[0m"
				wget https://archive.org/download/google-chrome-stable_48.0.2564.116-1_i386/google-chrome-stable_48.0.2564.116-1_i386.deb
				echo -e "\e[31m[-] Done with download!\e[0m"
				echo -e "\e[1;33m[+] Installing google chrome\e[0m"
				dpkg -i google-chrome-stable_48.0.2564.116-1_i386.deb
				rm google-chrome-stable_48.0.2564.116-1_i386.deb
				apt-get -f install
				echo -e "\e[34m[-] Done installing Google Chrome on your Kali Linux system!\e[0m"
				echo -e "\e[34m[-] To run Google Chrome, use command: /usr/bin/google-chrome-stable --no-sandbox --user-data-dir\e[0m"
			else
				echo -e "\e[1;33m[+] Downloading Google Chrome for Debian 64bit\e[0m"
				wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
				echo -e "\e[31m[-] Done with download!\e[0m"
				echo -e "\e[1;33m[+] Installing Google Chrome\e[0m"
				dpkg -i google-chrome-stable_current_amd64.deb
				rm google-chrome-stable_current_amd64.deb
				apt-get -f install
				echo -e "\e[34m[-] Done installing Google Chrome on your Kali Linux system!\e[0m"
				echo -e "\e[34m[-] To run Google Chrome, use command: /usr/bin/google-chrome-stable --no-sandbox --user-data-dir\e[0m"
			fi
		else
			echo -e "\e[34m[-] Ok,maybe later !\e[0m"
		fi
}
######### Install Tor Browser
function installtorbrowser {
	echo -e "\e[1;33mThis option will install Tor Browser.\e[0m"
	echo "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
			read -p "Are you using a 32bit or 64bit operating system [ENTER: 32 or 64]? " operatingsys
			if [ "$operatingsys" == "32" ]; then 
				echo -e "\e[1;33m[+] Downloading Tor Browser 32bit\e[0m"
				cd /root/Desktop
				wget https://www.torproject.org/dist/torbrowser/6.5.1/tor-browser-linux32-6.5.1_en-US.tar.xz
				echo -e "\e[31m[-] Done with download!\e[0m"
				echo -e "\e[1;33m[+] Installing Tor Browser\e[0m"
				tar -xf tor-browser-linux32-6.0.5_en-US.tar.xz
				cd /root/Desktop/tor-browser_en-US/Browser/
				mv start-tor-browser start-tor-browser.txt
				sed -i 's/`id -u`" -eq 0/`id -u`" -eq 1/g' start-tor-browser.txt
				mv start-tor-browser.txt start-tor-browser
				cd ..
				ls -ld
				chown -R root:root .
				ls -ld
				echo -e "\e[34m[-] Done installing Tor Browser on your Kali Linux system!\e[0m"
			else
				cd /root/Desktop
				wget https://www.torproject.org/dist/torbrowser/6.5.1/tor-browser-linux64-6.5.1_en-US.tar.xz
				echo -e "\e[31m[-] Done with download!\e[0m"
				echo -e "\e[1;33m[+] Installing Tor Browser\e[0m"
				tar -xf tor-browser-linux64-6.0.5_en-US.tar.xz
				cd /root/Desktop/tor-browser_en-US/Browser/
				mv start-tor-browser start-tor-browser.txt
				sed -i 's/`id -u`" -eq 0/`id -u`" -eq 1/g' start-tor-browser.txt
				mv start-tor-browser.txt start-tor-browser
				cd ..
				ls -ld
				chown -R root:root .
				ls -ld
				echo -e "\e[34m[-] Done installing Tor Browser on your Kali Linux system!\e[0m"
			fi
		else
			echo -e "\e[34m[-] Ok,maybe later !\e[0m"
		fi
}
######## Install VPN
function installvpn {
	echo -e "\e[1;31mThis option will install VPN!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing VPN ======\033[m"
				sleep 2
				apt-get -y install network-manager-openvpn
				apt-get -y install network-manager-openvpn-gnome
				apt-get -y install network-manager-pptp
				apt-get -y install network-manager-pptp-gnome
				apt-get -y install network-manager-strongswan
				apt-get -y install network-manager-vpnc
				apt-get -y install network-manager-vpnc-gnome
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Archive-Manager
function installarchivemanager {
	echo -e "\e[1;31mThis option will install Archive Manager!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Archive Manager ======\033[m"
				sleep 2
				apt-get -y install unrar unace rar unrar p7zip zip unzip p7zip-full p7zip-rar file-roller
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Gdebi
function installgdebi {
	echo -e "\e[1;31mThis option will install Gdebi!\e[0m"
	echo -e "\e[1;31mgdebi lets you install local deb packages resolving and installing its dependencies. apt does the same, but only for remote (http, ftp) located packages.!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Gdebi ======\033[m"
				sleep 2
				apt-get -y install gdebi &>/dev/nul
				echo -e "\033[32m====== Done Installing Gdebi ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install bittorrent client
function installbittorrent {
	echo -e "\e[1;31mThis option will install bittorrent!\e[0m"
	echo -e "\e[1;31mThis is a transitional dummy package to ensure clean upgrades from old releases (the package deluge-torrent is replaced by deluge)!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing bittorrent ======\033[m"
				sleep 2
				apt-get -y install transmission
				echo -e "\033[32m====== Done Installing bittorrent ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Fix Sound Mute
function installfixsoundmute {
	echo -e "\e[1;31mThis option will fix sound mute on Kali Linux on boot!\e[0m"
	echo -e ""
	echo -e "Do you want to install alsa-utils to fix it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Fixing sound mute ======\033[m"
				sleep 2
				apt-get -y install alsa-utils
				echo -e "\033[32m====== Done Installing alsa-utils ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Change Kali Login Wallpaper
function installchangelogin {
	echo -e "\e[1;31mThis option will change Kali Login Wallpaper!\e[0m"
	echo -e "\e[1;31mPlace wallpaper that you want to make as Kali Login Wallpaper on Desktop\e[0m"
	echo -e "\e[1;31mAfter that, Rename it to "login-background.png" (.png format)\e[0m"
	echo -e ""
	echo -e "Do you want to change it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Changing Kali Login Wallpaper ======\033[m"
				sleep 2
				cd /usr/share/images/desktop-base/
				mv login-backgroung.{png,png.bak}
				mv /root/Desktop/login-background.png /usr/share/images/desktop-base/
				echo -e "\033[32m====== Done Changing ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Firefox
function installfirefox {
	echo -e "\e[1;31mThis option will install Firefox!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Firefox ======\033[m"
				sleep 2
				apt-get -y remove iceweasel
				echo -e deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main | tee -a /etc/apt/sources.list > /dev/null
				apt-key adv –recv-keys –keyserver keyserver.ubuntu.com C1289A29
				apt-get update
				apt-get --force-yes install firefox-mozilla-build				
				echo -e "\033[32m====== Done Installing ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install MinGW
function installMinGW {
	echo -e "\e[1;31mThis option will install MinGW!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing MinGW ======\033[m"
				sleep 2
				apt-get -y -qq install mingw-w64 binutils-mingw-w64 gcc-mingw-w64 cmake
				apt-get -y -qq install mingw-w64-dev mingw-w64-tools
				apt-get -y -qq install gcc-mingw-w64-i686 gcc-mingw-w64-x86-64
				apt-get -y -qq install mingw32				
				echo -e "\033[32m====== Done Installing ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Vmware
function installVmware {
	echo -e "\e[1;31mThis option will install Vmware-tools!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Vmware Tools ======\033[m"
				sleep 2
				apt-get -y -qq install open-vm-tools-desktop fuse 				
				echo -e "\033[32m====== Done Installing ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install fix device
function installfixdevice {
	echo -e "\e[1;31mThis option will fix device mananged error!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Fixing ======\033[m"
				sleep 2
				mv /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.txt
				sed -i 's/false/true/g' /etc/NetworkManager/NetworkManager.txt
				mv /etc/NetworkManager/NetworkManager.txt /etc/NetworkManager/NetworkManager.conf
				echo -e "\033[32m====== Done Fixing ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install installwirelessdriver
function installwirelessdriver {
	echo -e "\e[1;31mThis option will Install Wifi card driver in Kali Linux!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				firefox https://www.youtube.com/watch?v=AZ0lPu9NhWQ
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install installtransparent
function installtransparent {
	echo -e "\e[1;31mThis option will Transparent-top bar-notification-windows on Kali Linux!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				firefox https://www.youtube.com/watch?v=S3Dex1ltDs4
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Java version 8
function installjava {
	echo -e "\e[1;31mThis option will install java!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Java ======\033[m"
				sleep 2
				echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
				echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
				apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
				apt-get update
				apt-get -y install oracle-java8-installer
				echo -e "\033[32m====== Done Installing ======\033[m"
				echo -e "\033[32mTo remove java version 1.8\033[m"
				echo -e "\033[32mapt-get --purge remove oracle-java8-installer\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Sopcast
function installsopcast {
	echo -e "\e[1;31mThis option will install sopcast!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Sopcast ======\033[m"
				sleep 2
				wget https://launchpad.net/~jason-scheunemann/+archive/ppa/+files/sp-auth_3.2.6~ppa1~precise3_i386.deb
				dpkg -i sp-auth_3.2.6~ppa1~precise3_*.deb
				apt-get -f install
				wget https://launchpad.net/~jason-scheunemann/+archive/ppa/+files/sopcast-player_0.8.5~ppa~precise1_i386.deb
				dpkg -i sopcast-player_0.8.5~ppa~precise1_*.deb
				apt-get -f install
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install nvidia
function installnvidia {
	echo -e "\e[1;31mThis option will install nvidia GPU driver!\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing nvidia GPU driver ======\033[m"
				sleep 2
				apt update && apt dist-upgrade -y
				apt install -y ocl-icd-libopencl1 nvidia-driver nvidia-cuda-toolkit
				nvidia-smi
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install fix sound kali linux 2016.2
function installsoudkali2016 {
	echo -e "\e[1;31mThis option will fix sound mute and start pulseaudio on startup!\e[0m"
	echo -e ""
	echo -e "Do you want to fix it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Fixing Sound ======\033[m"
				sleep 2
				systemctl --user enable pulseaudio
				systemctl --user start pulseaudio
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Wordlist
function installwordlist {
	echo -e "\e[1;31mThis option will download more wordlist to your Kali Linux system!\e[0m"
	echo -e ""
	echo -e "Do you want to download it ? (Y/N)"mv /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.txt
				sed -i 's/false/true/g' /etc/NetworkManager/NetworkManager.txt
				mv /etc/NetworkManager/NetworkManager.txt /etc/NetworkManager/NetworkManager.conf
				echo -e "\033[32m====== Done Fixing ======\033[m"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Downloading wordlist ======\033[m"
				sleep 2
				echo -e "\n $GREEN[+]$RESET Updating wordlists ~ collection of wordlists"
				apt-get -y -qq install curl
				#--- Extract rockyou wordlist
				[ -e /usr/share/wordlists/rockyou.txt.gz ] && gzip -dc < /usr/share/wordlists/rockyou.txt.gz > /usr/share/wordlists/rockyou.txt   #gunzip rockyou.txt.gz
				#rm -f /usr/share/wordlists/rockyou.txt.gz
				#--- Extract sqlmap wordlist
				#unzip -o -d /usr/share/sqlmap/txt/ /usr/share/sqlmap/txt/wordlist.zip
				#--- Add 10,000 Top/Worst/Common Passwords
				mkdir -p /usr/share/wordlists/
				(curl --progress -k -L "http://xato.net/files/10k most common.zip" > /tmp/10kcommon.zip && unzip -q -o -d /usr/share/wordlists/ /tmp/10kcommon.zip 2>/dev/null) || (curl --progress -k -L "http://download.g0tmi1k.com/wordlists/common-10k_most_common.zip" > /tmp/10kcommon.zip && unzip -q -o -d /usr/share/wordlists/ /tmp/10kcommon.zip)   #***!!! hardcoded version! Need to manually check for updates
				mv -f /usr/share/wordlists/10k{\ most\ ,_most_}common.txt
				#--- Linking to more - folders
				[ -e /usr/share/dirb/wordlists ] && ln -sf /usr/share/dirb/wordlists /usr/share/wordlists/dirb
				#--- Linking to more - files
				#ln -sf /usr/share/sqlmap/txt/wordlist.txt /usr/share/wordlists/sqlmap.txt
				##--- Not enough? Want more? Check below!
				##apt-cache search wordlist
				##find / \( -iname '*wordlist*' -or -iname '*passwords*' \) #-exec ls -l {} \;
				#--- Remove old temp files
				rm -f /tmp/10kcommon.zip			
				echo -e "\033[32m====== Done Downloading ======\033[m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Software and System Tools menu
function softwaresandystemtools {
clear
echo -e "
\033[31m#######################################################\033[m
                Software and System Tools
\033[31m#######################################################\033[m"
select menusel in "VirtualBox" "Arc theme" "Bleachbit" "Google Chrome" "GoldenDict" "Sopcast" "Flash" "Transparent-top bar-notification-windows on Kali Linux" "Install Wifi card driver in Kali Linux" "Java" "Pinta" "RecordMyDesktop" "GnomeTweakTool" "ibus" "libreoffice" "knotes" "VPN" "VPN-BOOK" "Tor Browser" "Fix Sound Mute" "Fix Sound Mute on Kali Linux 2016.2" "Archive-Manager" "Gdebi" "bittorrent client" "NVIDIA GPU Drivers" "system-config-samba" "Fix Device not managed error" "Change Kali Login Wallpaper" "Firefox" "MinGW" "Vmare-tools" "Install All" "Back to Main"; do
case $menusel in
	"VirtualBox")
		installvirtualbox
		pause
		softwaresandystemtools ;;

	"Arc theme")
		installarctheme
		pause
		softwaresandystemtools ;;

	"NVIDIA GPU Drivers")
		installnvidia
		pause
		softwaresandystemtools ;;

	"Fix Sound Mute on Kali Linux 2016.2")
		installsoudkali2016
		pause
		softwaresandystemtools ;;

	"Transparent-top bar-notification-windows on Kali Linux")
		installtransparent
		pause
		softwaresandystemtools ;;

	"Sopcast")
		installsopcast
		pause
		softwaresandystemtools ;;
	
	"Firefox")
		installfirefox
		pause
		softwaresandystemtools ;;
	"Install Wifi card driver in Kali Linux")
		installwirelessdriver
		pause
		softwaresandystemtools ;;
	"Java")
		installjava
		pause
		softwareandsystemtools ;;

	"MinGW")
		installMinGW
		pause
		softwaresandystemtools ;;
		
	"Vmare-tools")
		installVmware
		pause
		softwaresandystemtools ;;
	"Bleachbit")
		installbleachbit
		pause
		softwaresandystemtools ;;
	
	"GoldenDict")
		installGoldendict
		pause
		softwaresandystemtools ;;
		
	"Flash")
		installflash
		pause
		softwaresandystemtools ;;
	"system-config-samba")
		installsystem-config-samba
		pause
		softwaresandystemtools ;;
		
	"Pinta")
		installpinta
		pause
		softwaresandystemtools ;;
	"Google Chrome")
		installgooglechrome
		pause
		softwaresandystemtools ;;
	"RecordMyDesktop")
		installrecordmydesktop
		pause
		softwaresandystemtools ;;
	"GnomeTweakTool")
		installgnometweaktool
		pause
		softwareandsystemtools ;;
	"ibus")
		installibus
		pause
		softwaresandystemtools ;;
	"libreoffice")
		installlibreoffice
		pause
		softwareandsystemtools ;;
	"knotes")
		installknotes
		pause
		softwaresandystemtools ;;
	"VPN")
		installvpn
		pause
		softwaresandystemtools ;;
	"VPN-BOOK")
		installvpnbook
		pause
		softwaresandystemtools ;;
	"Tor Browser")
		installtorbrowser
		pause
		softwaresandystemtools ;;
	"Fix Sound Mute")
		installfixsoundmute
		pause
		softwaresandystemtools ;;
	"Archive-Manager")
		installarchivemanager
		pause
		softwaresandystemtools ;;
	"Gdebi")
		installgdebi
		pause
		softwaresandystemtools ;;
	"bittorrent client")
		installbittorrent
		pause
		softwaresandystemtools ;;
	"Fix Device not managed error")
		installfixdevice
		pause
		softwaresandystemtools ;;
	"Change Kali Login Wallpaper")
		installchangelogin
		pause
		softwaresandystemtools ;;
	"Install All")
		installvirtualbox
		installbleachbit
		installGoldendict
		installflash
		installpinta
		installrecordmydesktop
		installgnometweaktool
		installibus
		installlibreoffice
		installknotes
		installvpnbook
		installvpn
		installtorbrowser
		installfixsoundmute
		installsoudkali2016
		installgooglechrome
		installarchivemanager
		installgdebi
		installbittorrent
		installfixdevice
		installchangelogin
		installsystem-config-samba
		installfirefox
		installMinGW
		installVmware
		echo -e "\e[32m[-] Done Installing Software and System Tools\e[0m"
		pause
		softwaresandystemtools ;;

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		softwaresandystemtools ;;
	
		
esac

break

done
}
######## Update metasploit
function updatemetasploit {
if [ ! -f /opt/dirs3arch.py ]; then
	echo -e "\e[1;31mThis option will update latest metasploit version!\e[0m"
	echo -e ""
	echo -e "Do you want to update it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Updating metasploit ======\033[m"
				sleep 2
				git clone https://github.com/rapid7/metasploit-framework.git /opt/exploitation/metasploit/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] Metasploit already updated !\e[0m"
	fi
}
######## Update Social Engineering Toolkit
function updateSET {
	echo -e "\e[1;31mThis option will update latest SET version!\e[0m"
	echo -e ""
	echo -e "Do you want to update it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Updating SET ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/set/
				git clone https://github.com/trustedsec/social-engineer-toolkit.git /opt/exploitation/set/
				mv /usr/share/set/config/ /opt/exploitation/set/
				echo -e "\e[32m[-] Done!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Update Beef
function updateBeef {
	echo -e "\e[1;31mThis option will update latest Beef version!\e[0m"
	echo -e ""
	echo -e "Do you want to update it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Updating SET ======\033[m"
				sleep 2
				git clone https://github.com/beefproject/beef.git /opt/exploitation/beef/
				echo -e "\e[32m[-] Done!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Update Veil-Evasion
function updateVeil {
	echo -e "\e[1;31mThis option will update latest Veil version!\e[0m"
	echo -e ""
	echo -e "Do you want to update it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Updating Veil-Evasion ======\033[m"
				sleep 2
				cd /opt/BypassAV/
				rm -rf Veil-Evasion/
				git clone https://github.com/Veil-Framework/Veil-Evasion.git /opt/BypassAV/Veil-Evasion/
				echo -e "\e[32m[-] Done!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install system-config-samba
function installsystem-config-samba {
	echo -e "\e[1;31mThis option will install system-config-samba!\e[0m"
	echo -e ""
	echo -e "Do you want to update it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing system-config-samba ======\033[m"
				sleep 2
				apt-get install -y build-essential gfortran checkinstall python-all-dev cdbs debhelper quilt intltool python-central rarian-compat pkg-config gnome-doc-utils samba python-libuser libuser1 python-glade2
				mkdir ~/tmp
				cd ~/tmp
				wget https://launchpad.net/ubuntu/+archive/primary/+files/system-config-samba_1.2.63.orig.tar.gz
				tar xvf system-config-samba_1.2.63.orig.tar.gz
				wget https://launchpad.net/ubuntu/+archive/primary/+files/system-config-samba_1.2.63-0ubuntu5.diff.gz
				gunzip system-config-samba_1.2.63-0ubuntu5.diff.gz
				patch -p0 < system-config-samba_1.2.63-0ubuntu5.diff
				cd system-config-samba-1.2.63/
				dpkg-buildpackage -uc -us
				sudo dpkg -i ../system-config-samba_1.2.63-0ubuntu5_all.deb
				sudo touch /etc/libuser.conf
				gksu system-config-samba
				echo -e "\e[32m[-] Done!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Update Backdoor Factory
function updateBackdoorFactory {
	echo -e "\e[1;31mThis option will update latest Backdoor Factory version!\e[0m"
	echo -e ""
	echo -e "Do you want to update it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Updating Backdoor Factory ======\033[m"
				sleep 2
				rm -rf /opt/BypassAV/the-backdoor-factory/
				git clone https://github.com/secretsquirrel/the-backdoor-factory.git /opt/BypassAV/the-backdoor-factory/
				cd /opt/BypassAV/the-backdoor-factory/
				./install.sh
				echo -e "\e[32m[-] Done!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Update tools to latest version
function updatetools {
clear
echo -e "
\033[35m#######################################################\033[m
                Update tools to latest version
\033[35m#######################################################\033[m"
select menusel in "Metasploit" "Beef" "Veil-Evasion" "Social Engineering Toolkit" "Backdoor Factory" "Update All" "Back to Main"; do
case $menusel in
	"Metasploit")
		updatemetasploit
		pause
		updatetools ;;
	"Beef")
		updateBeef
		pause
		updatetools ;;
	"Veil-Evasion")
		updateVeil
		pause
		updatetools ;;
	"Social Engineering Toolkit")
		updateSET
		pause
		updatetools ;;
	"Backdoor Factory")
		updateBackdoorFactory
		pause
		updatetools ;;

	"Update All")
		updatemetasploit
		updateBeef
		updateVeil
		updateSET
		updateBackdoorFactory
		echo -e "\e[32m[-] Done Updating\e[0m"
		pause
		updatetools ;;

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		updatetools ;;
	
		
esac

break

done
}
######## Install Backdoor-Factory
function installbackdoorfactory {
if [ ! -f /opt/BypassAV/the-backdoor-factory/backdoor.py ]; then
	echo -e "\e[1;31mThis option will install Backdoor-Factory!\e[0m"
	echo -e "\e[1;31mPatch PE, ELF, Mach-O binaries with shellcode\e[0m"
		echo -e "\e[1;31mHow to use backdoor-factory\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=z40MuTHVnIo\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Backdoor Factory ======\033[m"
				sleep 2
				git clone https://github.com/secretsquirrel/the-backdoor-factory.git /opt/BypassAV/the-backdoor-factory/
				cd /opt/BypassAV/the-backdoor-factory/
				./install.sh
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] Backdoor Factory already installed !\e[0m"
	fi
}
######## Install Fluxion
function installfluxion {
if [ ! -f /opt/wireless/fluxion ]; then
	echo -e "\e[1;31mThis option will install Fluxion!\e[0m"
	echo -e "\e[1;31mEvil Twin wireless attacking method\e[0m"
		echo -e "\e[1;31mHow to use fluxion\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=AfVhC5y3vXk\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Fluxion ======\033[m"
				sleep 2
				git clone https://github.com/deltaxflux/fluxion.git /opt/wireless/fluxion
				cd /opt/wireless/fluxion
				chmod +x Installer.sh
				./Installer.sh
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] Fluxion already installed !\e[0m"
	fi
}
######## Install pyobfuscate
function installpyobfuscate {
if [ ! -f /opt/BypassAV/pyobfuscate-master/pyobfuscate.py ]; then
	echo -e "\e[1;31mThis option will install pyobfuscate!\e[0m"
	echo -e "\e[1;31mA pyobfuscate fork made specifically to randomize and obfuscate python based payloads\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing pyobfuscate ======\033[m"
				sleep 2
				git clone https://github.com/byt3bl33d3r/pyobfuscate.git /opt/BypassAV/pyobfuscate-master/
				cd /opt/BypassAV/pyobfuscate-master/
				python setup.py install
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] pyobfuscate already installed !\e[0m"
	fi
}
######## Install Shellter
function installshellter {
if [ ! -f /usr/bin/shellter ]; then
	echo -e "\e[1;31mThis option will install Shellter!\e[0m"
	echo -e "\e[1;31mShellter is a dynamic shellcode injection tool, and probably the first dynamic PE infector ever created.\e[0m"
	echo -e "\e[1;31mHow to use shellter\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=XwJiZv625ks\e[0m"
	echo -e "\e[1;31mHow to create FUD using shellter\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=6Az-R9B2yEg\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Shellter ======\033[m"
				sleep 2
				apt-get -y install shellter
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] Shellter already installed !\e[0m"
	fi
}
######## Install Unicorn
function installunicorn {
if [ ! -f /opt/BypassAV/unicorn-master/unicorn.py ]; then
	echo -e "\e[1;31mThis option will install Unicorn!\e[0m"
	echo -e "\e[1;31mUnicorn is a simple tool for using a PowerShell downgrade attack and inject shellcode straight into memory.\e[0m"
	echo -e "\e[1;31mHow to use unicorn\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=7-yESVhWwyA\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Unicorn ======\033[m"
				sleep 2
				git clone https://github.com/trustedsec/unicorn.git /opt/BypassAV/unicorn-master
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] Unicorn already installed !\e[0m"
	fi
}
######## Install Avoid
function installavoid {

	echo -e "\e[1;31mThis option will install Avoid!\e[0m"
	echo -e "\e[1;31mMetasploit AV Evasion Tool\e[0m"
	echo -e "\e[1;31mHow to use Avoid\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=nKvHM0lzEJU\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Avoid ======\033[m"
				sleep 2
				rm -rf /opt/BypassAV/Avoid/
				git clone https://github.com/nccgroup/metasploitavevasion.git /opt/BypassAV/Avoid/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install autopwn
function installautopwn {
	echo -e "\e[1;31mThis option will install autopwn!\e[0m"
	echo -e "\e[1;31mSpecify targets and run sets of tools against them\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing autopwn ======\033[m"
				sleep 2
				git clone https://github.com/nccgroup/autopwn.git /opt/exploitation/WebApp/autopwn-master/
				cd /opt/exploitation/WebApp/autopwn-master/
				pip install -r requirements.txt
				python setup.py install
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install mitmf
function installmitmf {
if [ ! -f /opt/MITMf-master/mitmf.py ]; then
	echo -e "\e[1;31mThis option will install mitmf!\e[0m"
	echo -e "\e[1;31mFramework for Man-In-The-Middle attacks\e[0m"
	echo -e "\e[1;31mDefeat HTST to get HTTPS password\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=KtYWeeQ4hoI\e[0m"
	echo -e "\e[1;31mHow to use MITMF\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=0trxc7axE4Y\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing mitmf ======\033[m"
				sleep 2
				rm -rf /opt/Sniffing-Spoofing/mitmf/
				apt-get install python-dev python-setuptools libpcap0.8-dev libnetfilter-queue-dev libssl-dev libjpeg-dev libxml2-dev libxslt1-dev libcapstone3 libcapstone-dev libffi-dev file
				pip install virtualenvwrapper
				source /usr/bin/virtualenvwrapper.sh
				mkvirtualenv MITMf -p /usr/bin/python2.7
				git clone https://github.com/byt3bl33d3r/MITMf.git /opt/Sniffing-Spoofing/mitmf/
				cd  /opt/Sniffing-Spoofing/mitmf/
				cd MITMf && git submodule init && git submodule update --recursive
				pip install -r requirements.txt
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] autopwn already installed !\e[0m"
	fi
}
######## Install commix
function installcommix {
	echo -e "\e[1;31mThis option will install commix!\e[0m"
	echo -e "\e[1;31mAutomated All-in-One OS Command Injection and Exploitation Tool\e[0m"
	echo -e "\e[1;31mHow to use commix\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=W1FRe7BdK0I\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing commix ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/WebApp/commix-master/
				git clone https://github.com/stasinopoulos/commix.git /opt/exploitation/WebApp/commix-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install EyeWitness
function installeyswitness {
	echo -e "\e[1;31mThis option will install EyeWitness!\e[0m"
	echo -e "\e[1;31mEyeWitness is designed to take screenshots of websites, provide some server header info, and identify default credentials if possible.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing EyeWitness ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/WebApp/EyeWitness-master/
				git clone https://github.com/ChrisTruncer/EyeWitness.git /opt/intelligence-gathering/WebApp/EyeWitness-master/
				cd /opt/intelligence-gathering/WebApp/EyeWitness-master/setup/
				chmod a+x setup.sh
				./setup.sh
				
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install gcat
function installgcat {
	echo -e "\e[1;31mThis option will install gcat!\e[0m"
	echo -e "\e[1;31mA fully featured backdoor that uses Gmail as a C&C server\e[0m"
	echo -e "\e[1;31mHow to use gcat\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=wWQlBsTTqHQ\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing gcat ======\033[m"
				sleep 2
				rm -rm /opt/Maintaining-Access/OS-Backdoor/gcat-master/
				git clone https://github.com/byt3bl33d3r/gcat.git /opt/Maintaining-Access/OS-Backdoor/gcat-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install maligno
function installmaligno {
if [ ! -f /opt/BypassAV/maligno/maligno_srv.py ]; then
	echo -e "\e[1;31mThis option will install maligno!\e[0m"
	echo -e "\e[1;31mMaligno is an open source penetration testing tool written in Python that serves Metasploit payloads. It generates shellcode with msfvenom and transmits it over HTTP or HTTPS. The shellcode is encrypted with AES and encoded prior to transmission.\e[0m"
	echo -e "\e[1;31mHow to create FUD using maligno\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=dwOMiE13Y0s\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing maligno ======\033[m"
				sleep 2
				rm -rf /opt/BypassAV/maligno/
				cd /opt/
				mkdir BypassAV/
				cd BypassAV/
				mkdir maligno/
				cd /opt/BypassAV/maligno/
				wget https://www.encripto.no/tools/maligno-2.2.tar.gz
				tar -zxvf maligno-2.2.tar.gz
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
	else
		echo -e "\e[32m[-] maligno already installed !\e[0m"
	fi
}
######## Install wig
function installwig {
	echo -e "\e[1;31mThis option will install wig!\e[0m"
	echo -e "\e[1;31mWebApp Information Gatherer\e[0m"
	echo -e "\e[1;31mHow to use wig\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=CJyfrB9i6gs\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing wig ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/WebApp/wig/
				git clone https://github.com/jekyc/wig.git /opt/intelligence-gathering/WebApp/wig/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Windows Exploit Suggester
function installwindowsexploitsuggester {
	echo -e "\e[1;31mThis option will install Windows Exploit Suggester!\e[0m"
	echo -e "\e[1;31mThis tool compares a targets patch levels against the Microsoft vulnerability database in order to detect potential missing patches on the target. It also notifies the user if there are public exploits and Metasploit modules available for the missing bulletins.\e[0m"
	echo -e "\e[1;31mHow to use Windows Exploit Suggester\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=dm3iMkAWink\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Windows Exploit Suggester ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/Network/Windows-Exploit-Suggester/
				git clone https://github.com/GDSSecurity/Windows-Exploit-Suggester.git /opt/vulnerability-analysis/Network/Windows-Exploit-Suggester/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install shellcode_tools
function installshellcodetools {
	echo -e "\e[1;31mThis option will install shellcode tools!\e[0m"
	echo -e "\e[1;31mMiscellaneous tools written in Python, mostly centered around shellcodes.\e[0m"
	echo -e "\e[1;31mHow to use shellcode tools\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=q_HjKvIEae4\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Shellcode Tools ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/shellcode_tools-master/
				git clone https://github.com/MarioVilas/shellcode_tools.git /opt/exploitation/Network/shellcode_tools-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install DAws
function installdaws {
	echo -e "\e[1;31mThis option will install DAws-master!\e[0m"
	echo -e "\e[1;31mAdvanced Web Shell\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing DAws-master ======\033[m"
				sleep 2
				rm -rf /opt/Maintaining-Access/Web-Backdoor/DAws-master/
				git clone https://github.com/dotcppfile/DAws.git /opt/Maintaining-Access/Web-Backdoor/DAws-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Serbot
function installserbot {
	echo -e "\e[1;31mThis option will install Serbot-master!\e[0m"
	echo -e "\e[1;31mAdvanced Controller/Server/Client Reverse Shell/Bot – Windows/Linux – Python\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Serbot ======\033[m"
				sleep 2
				rm -rf /opt/Maintaining-Access/OS-Backdoor/Serbot-master/
				git clone https://github.com/dotcppfile/Serbot.git /opt/Maintaining-Access/OS-Backdoor/Serbot-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Pompem
function installpompem {
	echo -e "\e[1;31mThis option will install Pompem-master!\e[0m"
	echo -e "\e[1;31mFind exploit tool\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Pompem ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Pompem-master/
				git clone https://github.com/rfunix/Pompem.git /opt/exploitation/Pompem-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install LaZagne
function installLazagne {
	echo -e "\e[1;31mThis option will install LaZagne!\e[0m"
	echo -e "\e[1;31mCredentials recovery project\e[0m"
	echo -e "\e[1;31mHow to use LaZagne\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=KF2k7Pmu7t4\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing LaZagne ======\033[m"
				sleep 2
				rm -rf /opt/Post-Exploitation/LaZagne-master/
				git clone https://github.com/AlessandroZ/LaZagne.git /opt/Post-Exploitation/LaZagne-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Empire
function installempire {
	echo -e "\e[1;31mThis option will install empire!\e[0m"
	echo -e "\e[1;31mEmpire is a pure PowerShell post-exploitation agent.\e[0m"
	echo -e "\e[1;31mHow to use Empire (Hello Powershell, Install Empire, convert powershell command, backdoor using empire...\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=YJwdmVUMFm4&list=PLTsHz_e2nqNlgTjj_kxTJ1RAFzfd88LP9\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Empire ======\033[m"
				sleep 2
				rm -rf /opt/Post-Exploitation/Empire/
				git clone https://github.com/PowerShellEmpire/Empire.git /opt/Post-Exploitation/Empire/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Linux Exploit Suggester
function installLinuxexploitsuggester {
	echo -e "\e[1;31mThis option will install Linux Exploit Suggester!\e[0m"
	echo -e "\e[1;31mLinux Exploit Suggester; based on operating system release number\e[0m"
	echo -e "\e[1;31mHow to use Linux Exploit Suggester\e[0m"
	echo -e "\e[1;32mhttps://www.youtube.com/watch?v=vBaHcKdFpc8\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Linux Exploit Suggester ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/Network/Linux_Exploit_Suggester-master/
				git clone https://github.com/PenturaLabs/Linux_Exploit_Suggester.git /opt/vulnerability-analysis/Network/Linux_Exploit_Suggester-master/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install discover
function installdiscover {
	echo -e "\e[1;31mThis option will install discover!\e[0m"
	echo -e "\e[1;31mFor use with Kali Linux. Custom bash scripts used to automate various pentesting tasks.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing discover ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/Network/discover/
				git clone https://github.com/leebaird/discover.git /opt/intelligence-gathering/Network/discover/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install masscan
function installmasscan {
	echo -e "\e[1;31mThis option will install masscan!\e[0m"
	echo -e "\e[1;31mTCP port scanner, spews SYN packets asynchronously, scanning entire Internet in under 5 minutes.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing masscan ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/Network/masscan/
				git clone https://github.com/robertdavidgraham/masscan.git /opt/intelligence-gathering/Network/masscan/
				cd /opt/intelligence-gathering/Network/masscan/
				apt-get -y install git gcc make libpcap-dev
				make
				cd bin/
				cp masscan /usr/bin/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install rawr
function installrawr {
	echo -e "\e[1;31mThis option will install rawr !\e[0m"
	echo -e "\e[1;31mRapid Assessment of Web Resources\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing RAWR  ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/WebApp/rawr/
				git clone https://bitbucket.org/al14s/rawr.git /opt/intelligence-gathering/WebApp/rarw/
				cd /opt/intelligence-gathering/WebApp/rawr/
				./install.sh y
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install recon-ng
function installrecon-ng {
	echo -e "\e[1;31mThis option will install recon-ng !\e[0m"
	echo -e "\e[1;31mRecon-ng is a full-featured Web Reconnaissance framework written in Python.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Recon-ng  ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/WebApp/recon-ng/
				git clone https://bitbucket.org/LaNMaSteR53/recon-ng/ /opt/intelligence-gathering/WebApp/recon-ng/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install seclist
function installseclist {
	echo -e "\e[1;31mThis option will install seclist!\e[0m"
	echo -e "\e[1;31m  \e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing seclist ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/seclist/
				git clone https://github.com/danielmiessler/SecLists.git /opt/intelligence-gathering/seclist/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install golismero
function installgolismero {
	echo -e "\e[1;31mThis option will install golismero!\e[0m"
	echo -e "\e[1;31mGoLismero - The Web Knife http://golismero-project.com/\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing golismero ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/WebApp/golismero/
				git clone  /opt/vulnerability-analysis/WebApp/golismero/
				cd /opt/vulnerability-analysis/golismero/
				apt-get -y install python2.7 python2.7-dev python-pip python-docutils git perl nmap sslscan
				pip install -r requirements.txt
				pip install -r requirements_unix.txt
				ln -s /opt/vulnerability-analysis/WebApp/golismero/golismero.py /usr/bin/golismero
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install wpscan
function installwpscan {
	echo -e "\e[1;31mThis option will install wpscan!\e[0m"
	echo -e "\e[1;31mA black box WP scanner\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing WPScan ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/WebApp/wpscan/
				git clone https://github.com/wpscanteam/wpscan/ /opt/vulnerability-analysis/WebApp/wpscan/
				apt-get -y install git ruby ruby-dev libcurl4-openssl-dev make
				cd /opt/vulnerability-analysis/WebApp/wpscan/
				gem install bundler
				bundle install --without test --path vendor/bundle
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install owtf
function installowtf {
	echo -e "\e[1;31mThis option will install owtf!\e[0m"
	echo -e "\e[1;31mOWASP OWTF, the Offensive (Web) Testing Framework, is an OWASP+PTES-focused try to unite great tools and make pen testing more efficient, written mostly in Python\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing owtf ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/WebApp/owtf/
				cd /opt/vulnerability-analysis/WebApp/
				wget https://raw.githubusercontent.com/owtf/bootstrap-script/master/bootstrap.sh
				chmod +x bootstrap.sh
				./bootstrap.sh
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install zarp
function installzarp {
	echo -e "\e[1;31mThis option will install zarp!\e[0m"
	echo -e "\e[1;31mNetwork Attack Tool\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing zarp ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/zarp/
				git clone https://github.com/hatRiot/zarp.git /opt/exploitation/Network/zarp/
				cd /opt/exploitation/Network/zarp/
				pip install -r requirements.txt
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install clusterd
function installclusterd {
	echo -e "\e[1;31mThis option will install clusterd!\e[0m"
	echo -e "\e[1;31mapplication server attack toolkit\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing clusterd ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/WebApp/clusterd/
				git clone https://github.com/hatRiot/clusterd.git /opt/vulnerability-analysis/WebApp/clusterd/
				cd /opt/vulnerability-analysis/WebApp/clusterd/
				pip install -r requirements.txt
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install YSO-Mobile-Security-Framework
function installYSO-Mobile-Security-Framework {
	echo -e "\e[1;31mThis option will install YSO-Mobile-Security-Framework!\e[0m"
	echo -e "\3[1;31mMobile Security Framework is an intelligent, all-in-one open source mobile application (Android/iOS) automated pen-testing framework capable of performing static and dynamic analysis.\e[0m"
	echo -e "\e[1;31mTo Run: python manage.py runserver 127.0.0.1:8000 Open your browser and navigate to http://127.0.0.1:8000\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing YSO-Mobile-Security-Framework ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/Smartphone/YSO-Mobile-Security-Framework/
				git clone https://github.com/ajinabraham/YSO-Mobile-Security-Framework.git /opt/vulnerability-analysis/Smartphone/YSO-Mobile-Security-Framework/
				cd /opt/vulnerability-analysis/Smartphone/YSO-Mobile-Security-Framework/
				pip install Django==1.8
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install jsgifkeylogger
function installjsgifkeylogger {
	echo -e "\e[1;31mThis option will install jsgifkeylogger!\e[0m"
	echo -e "\e[1;31ma javascript keylogger included in a gif file\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing jsgifkeylogger ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/Javascript/jsgifkeylogger/
				git clone https://github.com/wopot/jsgifkeylogger.git /opt/vulnerability-analysis/Javascript/jsgifkeylogger/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install DSJS
function installDSJS {
	echo -e "\e[1;31mThis option will install DSJS!\e[0m"
	echo -e "\e[1;31mDamn Small JS Scanner\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing DSJS ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/Javascript/DSJS/
				git clone https://github.com/stamparm/DSJS.git /opt/vulnerability-analysis/Javascript/DSJS/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install brakeman
function installbrakeman {
	echo -e "\e[1;31mThis option will install brakeman!\e[0m"
	echo -e "\e[1;31mBrakeman is a static analysis tool which checks Ruby on Rails applications for security vulnerabilities.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing brakeman ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/brakeman/
				git clone https://github.com/presidentbeef/brakeman.git /opt/vulnerability-analysis/brakeman/
				gem install brakeman
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install sleepy-puppy
function installsleepy-puppy {
	echo -e "\e[1;31mThis option will install sleepy-puppy!\e[0m"
	echo -e "\e[1;31mBlind Cross-site Scripting Collector and Manager\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing sleepy-puppy ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/Javascript/sleepy-puppy/
				git clone https://github.com/stamparm/DSJS.git /opt/vulnerability-analysis/Javascript/sleepy-puppy/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install DarkCometExploit
function installDarkCometExploit {
	echo -e "\e[1;31mThis option will install DarkCometExploit!\e[0m"
	echo -e "\e[1;31mSmall python script to upload payload on a DarkComet C&C\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing DarkCometExploit ======\033[m"
				sleep 2
				rm -rf /opt/Maintaining-Access/OS-Backdoor/DarkCometExploit/
				git clone https://github.com/wopot/jsgifkeylogger.git /opt/Maintaining-Access/OS-Backdoor/DarkCometExploit/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install WS-Attacker
function installWS-Attacker {
	echo -e "\e[1;31mThis option will install WS-Attacker!\e[0m"
	echo -e "\e[1;31mWS-Attacker is a modular framework for web services penetration testing. \e[0m"
	echo -e "\e[1;31mGo to WS-Attacker directory and type: java -jar WS-Attacker-1.6-SNAPSHOT.jar\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing WS-Attacker ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/WebApp/WS-Attacker/
				git clone https://github.com/RUB-NDS/WS-Attacker.git /opt/exploitation/WebApp/WS-Attacker/
				apt-get -y install maven git
				cd /opt/exploitation/WebApp/WS-Attacker/
				mvn clean package -DskipTests
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install lumberjackjs
function installlumberjackjs {
	echo -e "\e[1;31mThis option will install lumberjackjs!\e[0m"
	echo -e "\e[1;31mUtility for credential harvesting\e[0m"
		echo -e "\e[1;31mView README.md for more detail.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing lumberjackjs ======\033[m"
				sleep 2
				rm -rf /opt/vulnerability-analysis/Javascript/lumberjackjs/
				git clone https://github.com/tomsteele/lumberjackjs.git /opt/vulnerability-analysis/Javascript/lumberjackjs/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install fuzzdb
function installfuzzdb {
	echo -e "\e[1;31mThis option will install fuzzdb!\e[0m"
	echo -e "\e[1;31mfuzzdb is the most comprehensive Open Source database of malicious inputs, predictable resource names, greppable strings for server response messages, and other resources like web shells.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing fuzzdb ======\033[m"
				sleep 2
				rm -rf /opt/intelligence-gathering/fuzzdb/
				git clone https://github.com/rustyrobot/fuzzdb.git /opt/intelligence-gathering/fuzzdb/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install ZCR-Shellcoder
function installZCR-Shellcoder {
	echo -e "\e[1;31mThis option will install ZCR-Shellcoder!\e[0m"
	echo -e "\e[1;31mZeroDay Cyber Research - ZCR Shellcoder - z3r0d4y.com Shellcode Generator\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing ZCR-Shellcoder ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/ZCR-Shellcoder/
				git clone https://github.com/Ali-Razmjoo/ZCR-Shellcoder.git /opt/exploitation/Network/ZCR-Shellcoder/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install inception
function installinception {
	echo -e "\e[1;31mThis option will install inception!\e[0m"
	echo -e "\e[1;31mInception is a physical memory manipulation and hacking tool exploiting PCI-based DMA. The tool can attack over FireWire, Thunderbolt, ExpressCard, PC Card and any other PCI/PCIe interfaces. http://www.breaknenter.org/projects/inception\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing inception ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/inception/
				git clone https://github.com/carmaa/inception.git /opt/exploitation/Network/inception/
				apt-get -y install git cmake g++ python3 python3-pip
				cd /opt/exploitation/Network/inception/
				wget https://freddie.witherden.org/tools/libforensic1394/releases/libforensic1394-0.2.tar.gz -O - | tar xz
				cd libforensic1394-0.2
				cmake CMakeLists.txt
				make install
				cd python
				python3 setup.py install
				cd /opt/exploitation/Network/inception/
				./setup.py install

			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install wpa-autopwn
function installwpa-autopwn {
	echo -e "\e[1;31mThis option will install wpa-autopwn!\e[0m"
	echo -e "\e[1;31mWPA/WPA2 autopwn script that parses captured handshakes and sends them to the Crackq\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing wpa-autopwn ======\033[m"
				sleep 2
				rm -rf /opt/Wireless/wpa-autopwn/
				git clone https://github.com/vnik5287/wpa-autopwn.git /opt/Wireless/wpa-autopwn/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install wifite
function installwifite {
	echo -e "\e[1;31mThis option will install wifite!\e[0m"
	echo -e "\e[1;31mAn automated wireless attack tool.\e[0m"
	echo -e "\e[1;31mHow to use wifite\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=3n_lugYLApw\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing wifite ======\033[m"
				sleep 2
				rm -rf /opt/Wireless/wifite/
				git clone https://github.com/derv82/wifite.git /opt/Wireless/wifite/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Crackq
function installCrackq {
	echo -e "\e[1;31mThis option will install Crackq!\e[0m"
	echo -e "\e[1;31mHashcrack.org GPU-accelerated password cracker\e[0m"
	echo -e "\e[1;31mAPI Key: c048070d8a60dfd454ea2847049b1e0700c4ed092a43a716ae8e0a08f0e3d444\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Crackq ======\033[m"
				sleep 2
				rm -rf /opt/Password-Cracking/Crackq/
				git clone https://github.com/vnik5287/Crackq.git /opt/Password-Cracking/Crackq/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install RIPS
function installRIPS {
	echo -e "\e[1;31mThis option will install RIPS!\e[0m"
	echo -e "\e[1;31mA static source code analyser for vulnerabilities in PHP scripts\e[0m"
	echo -e "\e[1;31mOpen your browser at http://localhost/rips-xx/\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing RIPS ======\033[m"
				sleep 2
				rm -rf /var/www/RIPS/
				git clone https://github.com/ripsscanner/rips.git /var/www/RIPS/
				cd /var/www/
				chmod R 777 RIPS/
				chmod R 775 RIPS/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install PACK
function installPACK {
	echo -e "\e[1;31mThis option will install PACK!\e[0m"
	echo -e "\e[1;31mPACK (Password Analysis and Cracking Kit)\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing PACK ======\033[m"
				sleep 2
				rm -rf /opt/Password-Cracking/pack
				git clone https://github.com/jklmnn/imagejs.git /opt/Password-Cracking/pack/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install imagejs
function installimagejs {
	echo -e "\e[1;31mThis option will install imagejs!\e[0m"
	echo -e "\e[1;31mSmall tool to package javascript into a valid image file.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing imagejs ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/WebApp/imagejs/
				git clone https://github.com/jklmnn/imagejs.git /opt/exploitation/WebApp/imagejs/
				cd /opt/exploitation/WebApp/imagejs/
				make
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install PyPhisher
function installPyPhisher {
	echo -e "\e[1;31mThis option will install PyPhisher!\e[0m"
	echo -e "\e[1;31mA simple python tool for phishing\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing PyPhisher ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/WebApp/PyPhisher/
				git clone https://github.com/sneakerhax/PyPhisher.git /opt/exploitation/WebApp/PyPhisher/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install backdoor
function installbackdoor {
	echo -e "\e[1;31mThis option will install backdoor!\e[0m"
	echo -e "\e[1;31mLinux backdoor implementation written in Python.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing backdoor ======\033[m"
				sleep 2
				rm -rf /opt/Maintaining-Access/OS-Backdoor/
				git clone https://github.com/jeffreysasaki/backdoor.git /opt/Maintaining-Access/OS-Backdoor/
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install payload
function installmpc {
	echo -e "\e[1;31mThis option will install mpc!\e[0m"
	echo -e "\e[1;31mLinux backdoor implMsfvenom Payload Creator (MPC).\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing MPC ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/mpc/
				git clone https://github.com/g0tmi1k/mpc.git /opt/exploitation/Network/mpc/
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install sparta
function installsparta {
	echo -e "\e[1;31mThis option will install sparta!\e[0m"
	echo -e "\e[1;31mNetwork Infrastructure Penetration Testing Tool.\e[0m"
	echo -e "\e[1;31mHow to use Sparta\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=YmViShf7_gs\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing sparta ======\033[m"
				sleep 2
				rm -rf /usr/share/sparta/
				git clone https://github.com/SECFORCE/sparta.git /usr/share/sparta/
				apt-get -y install python-elixir
				apt-get -y install ldap-utils rwho rsh-client x11-apps finger
				cd  /usr/share/
				chmod a+x sparta/
				cd /usr/share/sparta/
				cp sparta /usr/bin/
				cd /usr/bin/
				chmod a+x sparta
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install bettercap
function installbettercap {
	echo -e "\e[1;31mThis option will install bettercap!\e[0m"
	echo -e "\e[1;31mA complete, modular, portable and easily extensible MITM framework.\e[0m"
	echo -e "\e[1;31mHow to defeat HSTS to get HTTPS password using bettercap\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=1SpyWrL64ho\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing bettercap ======\033[m"
				sleep 2
				rm -rf /opt/Sniffing-Spoofing/bettercap/
				git clone https://github.com/evilsocket/bettercap /opt/Sniffing-Spoofing/bettercap/
				apt-get install ruby-dev libpcap-dev
				cd /opt/Sniffing-Spoofing/bettercap/
				gem build bettercap.gemspec
				sudo gem install bettercap*.gem
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Nosql-Exploitation-Framework
function installNosql-Exploitation-Framework {
	echo -e "\e[1;31mThis option will install Nosql-Exploitation-Framework!\e[0m"
	echo -e "\e[1;31mA Python Framework For NoSQL Scanning and Exploitation\e[0m"
	echo -e "\e[1;31mHow to use Nosql-exploitation framework\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=qZwjjD2L2Ls\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Nosql-Exploitation-Framework ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/WebApp/Nosql-Exploitation-Framework/
				git clone https://github.com/torque59/Nosql-Exploitation-Framework.git /opt/exploitation/WebApp/Nosql-Exploitation-Framework/
				cd /opt/exploitation/WebApp/Nosql-Exploitation-Framework/
				chmod a+x install.sh
				install.sh
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install PSRecon
function installpsrecon {
	echo -e "\e[1;31mThis option will install psrecon!\e[0m"
	echo -e "\e[1;31mPSRecon gathers data from a remote Windows host using PowerShell (v2 or later), organizes the data into folders, hashes all extracted data, hashes PowerShell and various system properties, and sends the data off to the security team. The data can be pushed to a share, sent over email, or retained locally.\e[0m"
	echo -e ""
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing PSRecon ======\033[m"
				sleep 2
				rm -rf /opt/Post-Exploitation/PSRecon/
				git clone https://github.com/gfoss/PSRecon.git /opt/Post-Exploitation/PSRecon/
				cd /opt/exploitation/WebApp/Nosql-Exploitation-Framework/
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install SPF
function installspf {
	echo -e "\e[1;31mThis option will install spf!\e[0m"
	echo -e "\e[1;31mSpeedPhishing Framework\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing SPF ======\033[m"
				sleep 2
				apt-get install build-essential python-dev python-pip phantomjs -y
				pip install dnspython
				pip install twisted
				rm -rf /opt/exploitation/WebApp/SPF/
				git clone https://github.com/tatanus/SPF.git /opt/exploitation/WebApp/SPF/
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Impacket
function installimpacket {
	echo -e "\e[1;31mThis option will install Impacket!\e[0m"
	echo -e "\e[1;31mImpacket is a collection of Python classes for working with network protocols.\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Impacket ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/Impacket/
				git clone https://github.com/CoreSecurity/impacket.git /opt/exploitation/Network/Impacket/
				cd /opt/exploitation/Network/Impacket/
				python setup.py install
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install aircrack-ng
function installaircrack {
	echo -e "\e[1;31mThis option will install aircrack-ng on Ubuntu/Linux Mint!\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing aircrack-ng ======\033[m"
				sleep 2
				apt-get install build-essential libssl-dev libnl-3-dev libnl-genl-3-dev dpkg-dev g++ g++-4.8 libc-dev-bin libc6-dev libstdc++-4.8-dev zlib1g-dev debian-keyring g++-multilib g++-4.8-multilib gcc-4.8-doc libstdc++6-4.8-dbg glibc-doc libstdc++-4.8-doc libalgorithm-merge-perl libssl-doc libalgorithm-diff-xs-perl libssl-dev build-essential
				wget http://download.aircrack-ng.org/aircrack-ng-1.2-rc4.tar.gz
				tar -xzf aircrack-ng-1.2-rc4.tar.gz
				cd aircrack-ng-1.2-rc4
				make && make install
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Hcon
function installhcon {
	echo -e "\e[1;31mThis option will install Hcon!\e[0m"
	echo -e "\e[1;31mOpen Source Penetration Testing / Ethical Hacking Framework\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing hcon ======\033[m"
				sleep 2
				/opt/exploitation/WebApp/Hcon/
				mkdir /opt/exploitation/WebApp/Hcon/
				wget http://sourceforge.net/projects/hconframework/files/HconFramework-Fire/HconSTF_0.5_Prime/HconSTF_v0.5_Linux_x86.tar.bz2
				mv HconSTF_v0.5_Linux_x86.tar.bz2 /opt/exploitation/WebApp/Hcon/
				cd /opt/exploitation/WebApp/Hcon/
				tar -xf HconSTF_v0.5_Linux_x86.tar.bz2
				chmod a+x /opt/exploitation/WebApp/Hcon/
				rm HconSTF_v0.5_Linux_x86.tar.bz2
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install miasm
function installmiasm {
	echo -e "\e[1;31mThis option will install miasm!\e[0m"
	echo -e "\e[1;31mReverse engineering framework in Python\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing miasm ======\033[m"
				sleep 2
				hg clone https://code.google.com/p/elfesteem/
				cd /elfesteem/
				python setup.py build
				sudo python setup.py install
				git clone git://repo.or.cz/tinycc.git /root/Desktop/tinycc/
				cd /root/Desktop/tinycc/
				./configure --disable-static && make && make install
				apt-get install llvm -y
				rm -rf /opt/miasm/
				git clone https://github.com/cea-sec/miasm.git /opt/miasm/
				cd /opt/miasm/
				python setup.py build
				python setup.py install
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install Harness
function installharness {
	echo -e "\e[1;31mThis option will install Harness!\e[0m"
	echo -e "\e[1;31mReverse engineering framework in Python\e[0m"
	echo -e "\e[1;31mHow to use Harness\e[0m"
	echo -e "\e[1;31mhttps://www.youtube.com/watch?v=3Za8IXtZG9k\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Harness ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/Harness/
				git clone https://github.com/Rich5/Harness.git /opt/exploitation/Network/Harness/
				cd /opt/exploitation/Network/Harness/
				wget http://python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz
				tar xf Python-3.4.3.tar.xz
				cd Python-3.4.3
				./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
				make && make altinstall
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######## Install netripper
function installnetripper {
	echo -e "\e[1;31mThis option will install netripper!\e[0m"
	echo -e "\e[1;31mNetRipper – this is a fairly recent tool that is positioned for the post-operating system based on Windows and uses a number of non-standard approach to extract sensitive data. It uses API hooking in order to intercept network traffic and encryption related functions from a low privileged user, being able to capture both plain-text traffic and encrypted traffic before encryption/after decryption. This tool was first demonstrated at the Defcon 23 in Vegas.\e[0m"
	echo -e "\e[1;31mHow to use netripper\e[0m"
	echo -e "\e[1;31mhttp://kali-linux.co/forums/topic/shellter-metasploit-netripper-bypass-antivirus-and-sniff-https-password\e[0m"
	echo -e "Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing netripper ======\033[m"
				sleep 2
				rm -rf /opt/exploitation/Network/netripper/
				git clone git clone https://github.com/NytroRST/NetRipper.git /opt/exploitation/Network/netripper/
				cd /opt/exploitation/Network/netriper/Metasploit
				cp netripper.rb /usr/share/metasploit-framework/modules/post/windows/gather/netripper.rb
				mkdir /usr/share/metasploit-framework/modules/post/windows/gather/netripper
				g++ -Wall netripper.cpp -o netripper
				cp netripper /usr/share/metasploit-framework/modules/post/windows/gather/netripper/netripper
				cd ../Release/
				cp DLL.dll /usr/share/metasploit-framework/modules/post/windows/gather/netripper/DLL.dll
				echo -e "\e[32m[-] Done Installing!\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
}
######### Install Hacking Tools
function hackingtools {
clear
echo -e "
\033[31m#######################################################\033[m
                Install Hacking Tools
\033[31m#######################################################\033[m"

select menusel in "Veil-Framework" "Fluxion" "Aircrack" "Metasploit Framework" "NetRipper" "Backdoor-Factory" "Shellter" "Unicorn" "avoid" "Harness" "Empire" "PSRecon" "SPF" "hcon" "miasm" "Impacket" "pyobfuscate" "Nosql-Exploitation-Framework" "bettercap" "Dirs3arch" "sparta" "autopwn" "mitmf" "commix" "EyeWitness" "gcat" "maligno" "wig" "Windows Exploit Suggester" "Linux Exploit Suggester" "shellcode_tools" "DAws" "Serbot" "Pompem" "LaZagne" "discover" "masscan" "rawr" "recon-ng" "seclist" "golismero" "wpscan" "zarp" "clusterd" "YSO-Mobile-Security-Framework" "jsgifkeylogger" "DarkCometExploit" "WS-Attacker" "lumberjackjs" "fuzzdb" "ZCR-Shellcoder" "wpa-autopwn" "Crackq" "RIPS" "wifite" "DSJS" "sleepy-puppy" "Brakeman" "inception" "owtf" "PACK" "imagejs" "backdoor" "PyPhisher" "mpc" "Wordlist" "Install All" "Back to Main"; do
case $menusel in 
	"Veil-Framework")
		installveil
		pause 
		hackingtools ;;

	"Metasploit Framework")
		installmetasploitframework
		pause 
		hackingtools ;;

	"NetRipper")
		installnetripper
		pause 
		hackingtools ;;

	"Harness")
		installharness
		pause
		hackingtools ;;
	
	"hcon")
		installhcon
		pause
		hackingtools ;;

	"Impacket")
		installimpacket
		pause
		hackingtools ;;

	"miasm")
		installmiasm
		pause
		hackingtools ;;


	"Emprise")
		installempire
		pause
		hackingtools ;;

	"PSRecon")
		installpsrecon
		pause
		hackingtools ;;

	"SPF")
		installspf
		pause
		hackingtools ;;


	"PSRecon")
		installpsrecon
		pause
		hackingtools ;;

	"Nosql-Exploitation-Framework")
		installNosql-Exploitation-Framework
		pause
		hackingtools ;;

	"avoid")
		installavoid
		pause
		hackingtools ;;	

	"bettercap")
		installbettercap
		pause
		hackingtools ;;

	"sparta")
		installsparta
		pause
		hackingtools ;;

	"mpc")
		installmpc
		pause
		hackingtools ;;

	"Wordlist")
		installwordlist
		pause
		hackingtools ;;
	"backdoor")
		installbackdoor
		pause
		hackingtools ;;
	"PyPhisher")
		installPyPhisher
		pause
		hackingtools ;;

	"imagejs")
		installimagejs
		pause
		hackingtools ;;
	"wifite")
		installwifite
		pause
		hackingtools ;;
	"owtf")
		installowtf
		pause
		hackingtools ;;
	"inception")
		installinception
		pause
		hackingtools ;;
	"PACK")
		installPACK
		pause
		hackingtool ;;
	"Brakeman")
		installbrakeman
		pause
		hackingtools ;;
	"DSJS")
		installDSJS
		pause
		hackingtools ;;
		
	"Backdoor-Factory")
		installbackdoorfactory
		pause
		hackingtools ;;
		
	"Shellter")
		installshellter
		pause
		hackingtools ;;
		
	"Unicorn")
		installunicorn
		pause 
		hackingtools ;;
		
	"pyobfuscate")
		installpyobfuscate
		pause 
		hackingtools ;;
		
	"Dirs3arch")
		installDirs3arch
		pause
		hackingtools ;;
		
	"autopwn")
		installautopwn
		pause 
		hackingtools ;;
		
	"mitmf")
		installmitmf
		pause 
		hackingtools ;;
				
	"commix")
		installcommix
		pause 
		hackingtools ;;
	
	"EyeWitness")
		installeyewitness
		pause
		hackingtools  ;;
		
	"gcat")
		installgcat
		pause
		hackingtools  ;;

	"maligno")
		installmaligno
		pause
		hackingtools  ;;
			
	"wig")
		installwig
		pause
		hackingtools ;;
		
	"Windows Exploit Suggester")
		installwindowsexploitsuggester
		pause
		hackingtools ;;

	"Linux Exploit Suggester")
		installLinuxexploitsuggester
		pause
		hackingtools ;;
		
	"shellcode_tools")
		installshellcodetools
		pause
		hackingtools ;;
		
	"DAws")
		installdaws
		pause
		hackingtools ;;
		
	"Serbot")
		installserbot
		pause
		hackingtools ;;
		
	"Pompem")
		installpompem
		pause
		hackingtools ;;
	"LaZagne")
		installLazagne
		pause
		hackingtools ;;
	"discover")
		installdiscover
		pause
		hackingtools ;;
	"masscan")
		installmasscan
		pause
		hackingtools ;;
	"rawr")
		installrawr
		pause
		hackingtools ;;
	"recon-ng")
		installrecon-ng
		pause
		hackingtools ;;
	"seclist")
		installseclist
		pause
		hackingtools ;;
	"golismero")
		installgolismero
		pause
		hackingtools ;;
	"wpscan")
		installwpscan
		pause
		hackingtools ;;
	"Aircrack")
		installaircrack
		pause
		hackingtools ;;
	
	"zarp")
		installzarp
		pause
		hackingtools ;;
	"clusterd")
		installclusterd
		pause
		hackingtools ;;
	"YSO-Mobile-Security-Framework")
		installYSO-Mobile-Security-Framework
		pause
		hackingtools ;;
	"jsgifkeylogger")
		installjsgifkeylogger
		pause
		hackingtools ;;
	"DarkCometExploit")
		installDarkCometExploit
		pause
		hackingtools ;;
	"WS-Attacker")
		installWS-Attacker
		pause
		hackingtools ;;
	"lumberjackjs")
		installlumberjackjs
		pause
		hackingtools ;;
	"fuzzdb")
		installfuzzdb
		pause
		hackingtools ;;
	"ZCR-Shellcoder")
		installZCR-Shellcoder
		pause
		hackingtools ;;
	"wpa-autopwn")
		installwpa-autopwn
		pause
		hackingtools ;;
	"Crackq")
		installCrackq
		pause
		hackingtools ;;
	"RIPS")
		installRIPS
		pause
		hackingtools ;;
	"sleepy-puppy")
		installsleepy-puppy
		pause
		hackingtools ;;
	"Fluxion")
		installfluxion
		pause
		hackingtools ;;
		
	"Install All")
		installfluxion
		installveil
		installbackdoorfactory
		installnetripper
		installshellter
		installunicorn
		installpyobfuscate
		installDirs3arch
		installautopwn
		installmitmf
		installcommix
		installeyewitness
		installgcat
		installwig
		installbettercap
		installmetasploitframework
		installaircrack
		installsparta
		installwindowsexploitsuggester
		installLinuxexploitsuggester
		installshellcodetools
		installdaws
		installserbot
		installpompem
		installLazagne
		installdiscover
		installmasscan
		installrawr
		installrecon-ng
		installseclist
		installzarp
		installclusterd		
		installYSO-Mobile-Security-Framework
		installjsgifkeylogger
		installDarkCometExploit
		installWS-Attacker
		installlumberjackjs
		installfuzzdb
		installZCR-Shellcoder
		installwpa-autopwn
		installCrackq
		installRIPS
                installsleepy-puppy
		installPACK
		installimagejs
		installbackdoor
		installPyPhisher
		installmpc
		echo -e "\e[32m[-] Done Installing hackingtools\e[0m"
		pause
		extras ;;
		

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		extras ;;
	
		
esac

break

done
}

#### pause function
function pause(){
   read -sn 1 -p "Press any key to continue..."
}
########################################################
##             Main Menu Section
########################################################
function mainmenu {
echo -e "
\033[32m################################################################################\033[m
\033[1;36m
|                                                                              |
|                          I love Security and Haking.                         |
|______________________________________________________________________________|
|                                                                              |
|                                                                              |
|                                                                              |
|                 User Name:          [   security    ]                        |
|                                                                              |
|                 Password:           [               ]                        |
|                                                                              |
|    My facebook: www.facebook.com/haking.cracking.tutorial                    |
|                                                                              |  
|    My youtube channel: www.youtube.com/c/penetrationtestingwithddos          |
|                                                                              |
|    My website: https://securityonline.info                                   |
|                                   [ OK ]                                     |
|______________________________________________________________________________|
\033[m                                        
                  	    Script by DDOS
                     	    Version : 5.0.2 \033[32m$version\033[m
\033[32m###############################################################################\033[m"

select menusel in "Update Kali" "Software and System Tools" "Install Hacking Tools" "Install WebAPP Hacking Lab" "Update tools to latest version" "Must View" "EXIT PROGRAM"; do
case $menusel in
	"Update Kali")
		updatekali
		clear ;;
	
	"Software and System Tools")
		softwaresandystemtools
		clear ;;
	
	"Install Hacking Tools")
		hackingtools 
		clear ;;
	"Install WebAPP Hacking Lab")
		WebAppLab
		clear ;;

	"Update tools to latest version")
		updatetools
		clear ;;

	"Must View")
		firefox https://www.facebook.com/haking.cracking.tutorial
		firefox https://www.youtube.com/c/penetrationtestingwithddos
		firefox https://securityonline.info
		pause
		clear ;;
	
	"EXIT PROGRAM")
		clear && exit 0 ;;
		
	* )
		screwup
		clear ;;
esac

break

done
}

while true; do mainmenu; done
