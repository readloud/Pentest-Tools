#!/bin/bash
# Post installation Kali linux
# KING SABRI | @KINGSABRI
#


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


BANNER()
{
  clear 
  echo ""
  echo ""
  echo ""
  echo "									"
  echo "      /$$$$$$              /$$           /$$   /$$           /$$ /$$	"
  echo "     /$$__  $$            | $$          | $$  /$$/          | $$|__/	"
  echo "    | $$  \__/  /$$$$$$  /$$$$$$        | $$ /$$/   /$$$$$$ | $$ /$$	"
  echo "    |  $$$$$$  /$$__  $$|_  $$_/        | $$$$$/   |____  $$| $$| $$	"
  echo "     \____  $$| $$$$$$$$  | $$          | $$  $$    /$$$$$$$| $$| $$	"
  echo "     /$$  \ $$| $$_____/  | $$ /$$      | $$\  $$  /$$__  $$| $$| $$	"
  echo "    |  $$$$$$/|  $$$$$$$  |  $$$$/      | $$ \  $$|  $$$$$$$| $$| $$	"
  echo "     \______/  \_______/   \___/        |__/  \__/ \_______/|__/|__/	"
  echo "									"                                                                    
                                                                                                                               

}

SYSTEM()
{
  COLORIZING

# Check if not root
  if [[ $EUID -ne 0 ]]; then
    echo "[!] You MUST be root to run this script!" 1>&2
    exit 1
  fi

# 
# System Update
# 
  echo  $(tput setaf 6)
  echo "[+] Updating system.."
  echo  $(tput sgr0)
  apt-get -y update
  apt-get -y upgrade

# 
# Install KDE full
# 
  echo  $(tput setaf 6)
  echo "[+] Installing KDE desktop.."
#   echo  $(tput sgr0)
  echo $(tput setaf 1)$(tput bold)
  read -p "[?] Do you want install KDE? [y/n] " iKDE
  echo ""
  echo $(tput sgr0)
  if [[ ${iKDE,,} == y ]]
    then
      apt-get -y install kde-full kde-plasma-desktop kde-workspace  kdeplasma-addons plasma-widget-networkmanagement plasma-widget-networkmanagement-dbg update-notifier-kde yakuake plasma-scriptengine-superkaramba gtk3-engines-unico gtk3-engines-oxygen ttf-mscorefonts-installer
  fi

  
#     
# enable bash completion in interactive shells
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Enabling bash completion.."
  echo ""
  echo $(tput sgr0)

  cp /etc/bash.bashrc /etc/bash.bashrc.orig
  cat << EOF >> /etc/bash.bashrc

#
# enable bash completion in interactive shells - Kali-setter
#
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

EOF

# 
# Install Compiling tools
# 
  echo $(tput setaf 1)$(tput bold)
  echo ""
  echo "[+] Installing kernel-headers, compiling tools & extras.."
  echo ""
  echo $(tput sgr0)
  
  apt-get -y install build-essential autotools-dev cdbs check checkinstall dctrl-tools debian-keyring devscripts dh-make diffstat dput equivs libapt-pkg-perl libauthen-sasl-perl libclass-accessor-perl libclass-inspector-perl libcommon-sense-perl libconvert-binhex-perl libcrypt-ssleay-perl libdevel-symdump-perl libfcgi-perl libhtml-template-perl libio-pty-perl libio-socket-ssl-perl libio-string-perl libio-stringy-perl libipc-run-perl libjson-perl libjson-xs-perl libmime-tools-perl libnet-libidn-perl libnet-ssleay-perl libossp-uuid-perl libossp-uuid16 libparse-debcontrol-perl libparse-debianchangelog-perl libpod-coverage-perl libsoap-lite-perl libsub-name-perl libtask-weaken-perl libterm-size-perl libtest-pod-perl libxml-namespacesupport-perl libxml-sax-expat-perl libxml-sax-perl libxml-simple-perl libyaml-syck-perl lintian lzma patchutils strace wdiff linux-headers-`uname -r` winetricks


# 
# Ruby settings
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Setting Ruby & extras.."
  echo ""
  echo $(tput sgr0)
  apt-get -y install ruby-full ruby-dev jruby libbytelist-java libpcap-dev libsp-gxmlcpp-dev libsp-gxmlcpp1 libxslt1.1 libxslt1-dev
  update-alternatives --config ruby
  gem install pry colorize mechanize pcaprub nokogiri jruby-openssl

# 
# Install missing Python libs for sqlmap ntlm aut
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Setting Python.."
  echo ""
  echo $(tput sgr0)
  apt-get -y install python-pip
  pip-python install python-ntlm

# 
# Install java Sun last release
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Setting Java Sun.."
  echo ""
  echo $(tput sgr0)
  apt-key adv --keyserver keys.gnupg.net --recv-keys 5CB26B26
  echo "deb http://www.duinsoft.nl/pkg debs all" | sudo tee -a /etc/apt/sources.list.d/duinsoft.list
  apt-get update
  apt-get -y install update-sun-jre
  update-alternatives --config java

}

SECURITY()
{
  COLORIZING

  mkdir /pentest
  cd /pentest 
# 
# Download BufferOverflowKit
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Download BufferOverflowKit.."
  echo ""
  echo $(tput sgr0)
  git clone https://github.com/KINGSABRI/BufferOverflow-Kit.git

  echo $(tput setaf 6)
  echo ""
  echo "[+] Setting Metasploit with postgress.."
  echo ""
  echo $(tput sgr0)
  
  service postgresql start
  service metasploit start

  update-rc.d postgresql enable
  update-rc.d metasploit enable  
  
# 
# Install beef framework full
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Installing beef framework.."
  echo ""
  echo $(tput sgr0)
  apt-get -y install beef-xss beef-xss-bundle
  echo $(tput setaf 2)
  echo "[!] You can find beef framework in the following path.."
  echo "/usr/share/beef-xss"
  echo $(tput sgr0)  
  sleep 2
  
# 
# Download external nmap scripts
# 
  # TODO : add extra nmap script to /usr/share/nmap/scripts/
  nmap --script-updatedb

#   
# Installing Subterfuge MITM framework
# 
  wget -c https://subterfuge.googlecode.com/files/SubterfugePublicBeta5.0.tar.gz
  tar -xzf Subterfuge* #&& cd subterfuge*
  echo "[!] Go to /pentest/subterfuge to continue Subterfuge installation"
#   ./install.py	# It's better to run it manually
  sleep 2
  
  cd -	# 
  
  
#
# Install additional security tools
#
  echo $(tput setaf 6)
  echo ""
  echo "[+] Install additional security tools"
  echo ""
  echo $(tput sgr0)
  echo "[-] Install arp tools"
  apt-get -y install arp-scan arpalert
  

#   
# Setting /var/www/tools
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Setting /var/www/tools folder.."
  echo ""
  echo $(tput sgr0)
  
  apt-get -y install windows-binaries
  mkdir -p /var/www/tools/shells && chmod -R 755 /var/www/tools
  cp /usr/share/windows-binaries/{nc.exe,plink.exe,vncviewer.exe,wget.exe} /var/www/tools/
  wget -c http://winscp.net/download/winscp514.zip && unzip winscp514.zip
  cp WinSCP.exe /var/www/tools/scp.exe
  
}


EXTRA_APPS()
{
  COLORIZING
  
#   
# Google chrome
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Installing Google chrome.."
  echo ""
  echo $(tput sgr0)
  wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
  dpkg -i google-chrome-stable_current_i386.deb

#   
# Skype
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Installing Skype.."
  echo ""
  echo $(tput sgr0)
  wget -c http://download.skype.com/linux/skype-debian_4.1.0.20-1_i386.deb
  dpkg -i skype-debian_4.1.0.20-1_i386.deb

# 
# Shutter
# 
  echo $(tput setaf 6)
  echo "[+] Installing Shutter.."
  echo $(tput sgr0) 
  apt-get -y install shutter

# 
# Install Compressing applications
# 
  echo $(tput setaf 6)
  echo "[+] Compressing/Decompressing applications.."
  echo $(tput sgr0) 
  apt-get -y install unace rar unrar p7zip zip unzip p7zip-full p7zip-rar sharutils uudeview mpack arj cabextract file-roller

# 
# Install flash
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Installing flash player.."
  echo ""
  echo $(tput sgr0)
  apt-get -y install flashplugin-nonfree flashplugin-nonfree-extrasound  

# 
# Install Wine extras 
# 
  echo $(tput setaf 6)
  echo ""
  echo "[+] Installing extras.."
  echo ""
  echo $(tput sgr0)
  apt-get -y install cabextract mono-complete
  echo "[-]" Installing .NET 2.0
  winetricks dotnet20
  echo "[-]" Installing .NET 3.5 SP1
  winetricks dotnet35sp1
  echo "[-]" Installing .NET 4.0
  winetricks dotnet40

}



# BANNER
SYSTEM
SECURITY
EXTRA_APPS


