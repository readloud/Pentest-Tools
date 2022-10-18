#!/usr/bin/env bash

# Reading entered domain
echo -e "Enter domain to enumerate subdomains:- " ;
read domain ;

# BOOT WEESLEYLUNA
echo -e "[+] BOOT OF WEESLEYLUNA";


# Creating directories
if [ ! -d "$domain" ];then
        mkdir $domain
fi


# Using assetfinder
echo -e "[+] Enumerating using assetfinder..."; 
assetfinder --subs-only ${domain} > $domain/assetfinder.txt -silent;

# Using subfinder
echo -e "[+] Enumerating using subfinder...";
subfinder -d ${domain} -o $domain/subfinder.txt -silent;

# Using amass
echo -e "[+] Enumerating using amass...";
amass enum --passive -d $domain -o $domain/amass.txt -silent;

# Enumerate Cert.sh
echo -e "[+] Enumerate CERT.SH...";
curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anew $domain/cert.txt

# Combining results httpx
echo "domains saved at $domain/domains.txt..."; 
cat $domain/assetfinder.txt $domain/subfinder.txt $domain/amass.txt $domain/cert.txt| httpx -silent | anew $domain/domains.txt
