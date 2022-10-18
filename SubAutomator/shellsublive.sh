#! /bin/bash

figlet "live domain sorting"
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
nc=$(tput sgr0)
read -p "${bold} ${green}ENTER DOMAIN NAME:${nc} ${normal}" dom
echo "~~~~~~~~~~~~~~~~~~~"
if [[ -z $dom ]]; then
echo "*****************"
echo "${red}invalid syntax! provide a valid domain name"
echo " Example:example.com${nc}"
else
echo "${green}STARTING ASSETFINDER ${nc}"
echo "~~~~~~~~~~~~~~~~~~"
assetfinder -subs-only $dom > sub1 
cat sub1
echo "^^^^^^^^^^^^^^^^^^^^^^^"

echo "${red}FINDING LIVE DOMAINS${nc}"
echo "^^^^^^^^^^^^^^^^^^^^^^^"
cat sub1 | httprobe > subslive
cat subslive 
echo "::::::::::::::::::::::"
rm sub1
fi

if [[ -s subslive ]]; then
echo "${green}SORTING DOMAINS${nc}"
echo "::::::::::::::::::::::"
sort -u subslive | tee sortted 
rm subslive
else
echo "*****************"
echo "${red}file is empty${nc}"
fi