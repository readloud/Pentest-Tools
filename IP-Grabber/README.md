# IP-Grabber
This tool will grab the ip address of a person when he opens the link

# Steps to run this tool on linux:
- git clone https://github.com/krishpranav/IP-Grabber
- cd IP-Grabber
- sudo chmod 777 *
- bash ip-grabber.sh

# Steps to run this tool on mac:
- git clone https://github.com/krishpranav/IP-Grabber
- cd IP-Grabber
- sudo chmod 777 *
- bash ip-grabber.sh

# Steps to run this tool on termux(android):
- apt update
- pkg update
- pkg install git
- git clone https://github.com/krishpranav/IP-Grabber
- cd IP-Grabber
- chmod +x *
- bash ip-grabber.sh

 ### after the victim opens the link you will get the ip of the victim you want to wait for 20 to 30 sec to get the full info of the particular ip
    
    NOTE: login.html has take from  https://github.com/kinghacker0/Black-Water/blob/master/sites/create/login.html
    
    TOOL IS CREATED BY [KRISNA PRANAV](https://github.com/krishpranav)

### require:

[Install ngrok](https://ngrok.com/download)

[Download TGZ file](sudo tar xvzf ~/Downloads/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin) Then extract ngrok from the terminal
~~~
sudo tar xvzf ~/Downloads/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
~~~
via Apt
~~~ 
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok
~~~
via Snap
~~~
snap install ngrok
~~~
Add authtoken
~~~
ngrok config add-authtoken <token>
~~~
Don’t have an authtoken? [Sign up](https://dashboard.ngrok.com/signup)
Start a tunnel
~~~
ngrok http 80
~~~
[Install PHP](https://computingforgeeks.com/how-to-install-php-on-kali-linux/)
Ensure your system is updated:
~~~
sudo apt update
~~~
~~~
sudo apt full-upgrade -y
[ -f /var/run/reboot-required ] && sudo reboot -f
~~~
Import the GPG key and add the PPA repository
~~~
sudo apt -y install lsb-release apt-transport-https ca-certificates
~~~
~~~
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
~~~
Then add repository.
~~~
echo "deb https://packages.sury.org/php/ bullseye main" | sudo tee /etc/apt/sources.list.d/php.list
~~~
update the apt package index
~~~
sudo apt update
~~~
~~~
sudo apt install php
~~~
`'Fixing error ‘Depends: libffi7 (>= 3.3~20180313)‘`

`The following packages have unmet dependencies:
 php7.4-common : Depends: libffi7 (>= 3.3~20180313) but it is not installable`

Download a newer release of [Libffi7](http://ftp.us.debian.org/debian/pool/main/libf/libffi) package
~~~
wget http://ftp.us.debian.org/debian/pool/main/libf/libffi/libffi7_3.3-6_amd64.deb
~~~
~~~
sudo dpkg -i libffi7_3.3-6_amd64.deb
~~~
~~~
sudo apt install php
~~~
Confirm PHP version installed
~~~
php -v
~~~
All additional PHP extensions can be installed with the command syntax:
~~~
sudo apt install phpx.x-xxx
~~~
Example:
~~~
sudo apt-get install php7.4-{cli,json,imap,bcmath,bz2,intl,gd,mbstring,mysql,zip
~~~
PHP configurations related to Apache is stored in /etc/php/7.4/apache2/php.ini
