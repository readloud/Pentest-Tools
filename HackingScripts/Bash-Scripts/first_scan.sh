#!/usr/bin/bash

if [ $# -lt 1 ]; then
  echo "Invalid usage: $0 <host>"
  exit
fi

if [ "$EUID" -ne 0 ]; then
  echo "[-] Script requires root permissions (e.g. nmap scan)"
  exit
fi

IP_ADDRESS=$1

echo "[+] Checking online status…"
ping -c1 -W1 -q "${IP_ADDRESS}" &>/dev/null
status=$(echo $?)

if ! [[ $status == 0 ]] ; then
  echo "[-] Target not reachable"
  exit
fi

echo "[+] Scanning for open ports…"
PORTS=$(nmap -p- -T4 ${IP_ADDRESS} | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
if [ -z "${PORTS}" ]; then
    echo "[-] No open ports found"
    exit
fi

echo "[+] Open ports: ${PORTS}"
echo "[+] Performing service scans…"
nmap -A "${IP_ADDRESS}" -p$PORTS -T4 -v
