#!/usr/bin/bash

if [ $# -lt 1 ]; then
  echo "Invalid usage: $0 <host>"
  exit
fi

HOST=$1
gobuster dir --url="${HOST}" --wordlist="/usr/share/wordlists/SecLists/Discovery/Web-Content/raft-large-words-lowercase.txt" -b "403,404"  "${@:2}"
