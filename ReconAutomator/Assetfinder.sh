#!/bin/bash
echo ${purple}"
################INFO#################
# Title: Automated Assetfinder
# Author: CODEX
################USAGE#################
# Eg.: ./Assetfinder.sh google.com
"
echo -e "\n"
echo -e "\n"

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`

url=$1

if [ ! -d "$url" ]; then
	mkdir $url
fi

if [ ! -d "$url/recon" ] ; then
	mkdir $url/recon
fi
	
echo ${blue}"[+] Harvesting Subdomains with Assetfinder..."
echo -e "\n"
echo ${yellow}"[+] Please Wait"
echo -e "\n"

assetfinder $url >> $url/recon/assets.txt
echo ${green}"[+] Search Completed"

echo -e "\n"
echo -e "\n"


echo ${red}"[+] Removing Extras"
cat $url/recon/assets.txt | grep $1 >> $url/rm $url/recon/assets.txt 

echo -e "\n"
echo ${green}"[+] Subdomains are in Final.txt"
