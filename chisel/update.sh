#!/bin/bash

echo "Updating scripts…"
wget --no-verbose https://raw.githubusercontent.com/initstring/uptux/master/uptux.py -O uptux.py
wget --no-verbose https://raw.githubusercontent.com/pentestmonkey/unix-privesc-check/master/upc.sh -O unix-privesc-check.sh
wget --no-verbose https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 -O pspy64
wget --no-verbose https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32 -O pspy
wget --no-verbose https://raw.githubusercontent.com/flozz/p0wny-shell/master/shell.php -O p0wny-shell.php
wget --no-verbose https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh -O lse.sh
wget --no-verbose https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh -O linux-exploit-suggester.sh
wget --no-verbose https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/linPEAS/linpeas.sh -O linpeas.sh
wget --no-verbose https://github.com/rebootuser/LinEnum/raw/master/LinEnum.sh -O LinEnum.sh
wget --no-verbose https://github.com/stealthcopter/deepce/raw/main/deepce.sh -O deepce.sh

echo "Updating Chisel…"
location=$(curl -s -I https://github.com/jpillora/chisel/releases/latest | grep -i "location: " | awk '{ print $2 }')
if [[ "$location" =~ ^https://github.com/jpillora/chisel/releases/tag/v(.*) ]]; then
  chisel_version=${BASH_REMATCH[1]}
  chisel_version=${chisel_version%%[[:space:]]}
  echo "Got Chisel version: ${chisel_version}"
  curl -s -L "https://github.com/jpillora/chisel/releases/download/v${chisel_version}/chisel_${chisel_version}_linux_386.gz"    | gzip -d > chisel
  curl -s -L "https://github.com/jpillora/chisel/releases/download/v${chisel_version}/chisel_${chisel_version}_linux_amd64.gz"  | gzip -d > chisel64
  curl -s -L "https://github.com/jpillora/chisel/releases/download/v${chisel_version}/chisel_${chisel_version}_windows_386.gz"  | gzip -d > win/chisel.exe
  curl -s -L "https://github.com/jpillora/chisel/releases/download/v${chisel_version}/chisel_${chisel_version}_windows_amd64.gz"  | gzip -d > win/chisel64.exe
fi

# TODO: add others
echo "Updating windows tools…"
wget --no-verbose https://live.sysinternals.com/accesschk.exe -O win/accesschk.exe
wget --no-verbose https://live.sysinternals.com/accesschk64.exe -O win/accesschk64.exe
wget --no-verbose https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/binaries/x86/Release/winPEASx86.exe -O win/winPEAS.exe
wget --no-verbose https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/binaries/x64/Release/winPEASx64.exe -O win/winPEASx64.exe
wget --no-verbose https://raw.githubusercontent.com/carlospolop/privilege-escalation-awesome-scripts-suite/master/winPEAS/winPEASbat/winPEAS.bat -O win/winPEAS.bat
