## CDNRECON - A Content Delivery Network recon tool

<b>CDNRECON is a reconnaissance tool that tries to find the origin or backend IP address of a website protected by a CDNs reverse proxy. You can use it to get a head start when penetration testing a client protected by one aswell as to find possible misconfigurations on your own server. What ever your use case may be, CDNRECON can also be used as a general recon / scanning tool since it automates some common recon tasks in the process.

<b>The things CDNRECON does:
- Checks the target domain nameservers
- Dumps DNS records with DNSDumpster
- Checks common subdomains and gets their IP addresses
- Checks if any of the IP addresses belong to Cloudflare
- Checks if any of the IP addresses belong to Akamai
- Checks if any of the IP addresses are using the AkamaiGHost server
- Optionally returns data from Shodan for possibly leaked IP addresses
- Optionally writes the results to target.com-results.txt file

Shodan API keys are NOT required. Altough it's recommended to supply them for maximum output, CDNRECON tries other things before using them.

 <b>Checking the nameservers, common subdomains and their IP addresses</b>
 ```
    __________  _   ______  ________________  _   __
   / ____/ __ \/ | / / __ \/ ____/ ____/ __ \/ | / /
  / /   / / / /  |/ / /_/ / __/ / /   / / / /  |/ / 
/ /___/ /_/ / /|  / _, _/ /___/ /___/ /_/ / /|  /  
\____/_____/_/ |_/_/ |_/_____/\____/\____/_/ |_/   
                                                   

[i] Checking cloudflare.com nameservers . . .
[+] cloudflare.com is pointing to Cloudflares nameservers
[+] Nameservers: ['ns3.cloudflare.com.', 'ns7.cloudflare.com.', 'ns4.cloudflare.com.', 'ns5.cloudflare.com.', 'ns6.cloudflare.com.']
==================================================
[i] Checking common subdomains . . .
[+] www.cloudflare.com is a valid domain
[+] mail.cloudflare.com is a valid domain
[+] blog.cloudflare.com is a valid domain
[+] support.cloudflare.com is a valid domain
==================================================
[i] Getting subdomain IP addresses . . .
[+] www.cloudflare.com has an IP address of 104.16.124.96
[+] mail.cloudflare.com has an IP address of 216.58.210.147
[+] blog.cloudflare.com has an IP address of 172.64.146.82
[+] support.cloudflare.com has an IP address of 104.18.39.119
==================================================
````
 <b>Checking if the IP addresses belong to Cloudflare</b>
````
==================================================
[i] Checking if 104.16.124.96 is Cloudflare . . .
[+] 104.16.124.96 is Cloudflare
[+] Ray-ID: 7556c47a2d879914-ARN
[+] Country: Canada
[i] Checking if 216.58.210.147 is Cloudflare . . .
[!] 216.58.210.147 is NOT cloudflare
[i] Checking if 104.18.41.174 is Cloudflare . . .
[+] 104.18.41.174 is Cloudflare
[+] Ray-ID: 7556c47c8bb615dc-ARN
[+] Country: Canada
[i] Checking if 104.18.39.119 is Cloudflare . . .
[+] 104.18.39.119 is Cloudflare
[+] Ray-ID: 7556c47e0d3afe2c-HEL
[+] Country: Canada
  
````
 <b>Checking if the IP addresses belong to Akamai and if they're using the AkamaiGHost server</b>
```
[i] Checking if 23.61.197.234 is Akamai . . .
[+] 23.61.197.234 Server detected as AkamaiGHost
[+] Country: Sweden
[i] Checking if 95.101.93.134 is Akamai . . .
[+] 95.101.93.134 Server detected as AkamaiGHost
[+] Country: Sweden
==================================================
````
<b>Returns data for non Cloudflare IP addresses from Shodan</b>
````
[i] Shodan results for 23.61.197.234
[+] ISP: Akamai Technologies, Inc.
[+] Country: Sweden
[+] Hostname(s): ['a23-61-197-234.deploy.static.akamaitechnologies.com', 'kbb.com']
[+] Domain(s): ['akamaitechnologies.com', 'kbb.com']
[+] Open port(s): [80, 443]
[i] Shodan results for 95.101.93.134
[+] ISP: Akamai Technologies, Inc.
[+] Country: Sweden
[+] Hostname(s): ['a95-101-93-134.deploy.static.akamaitechnologies.com', 'kbb.com']
[+] Domain(s): ['akamaitechnologies.com', 'kbb.com']
[+] Open port(s): [80, 443]
````
## Installation and usage

<b>Requires atleast python version 3.6 since it uses f-strings.
>Tested on Arch Linux. It should work on any Linux distribution and Windows.

<b>Clone the repository
```
$ sudo git clone https://github.com/Juuso1337/CDNRECON
```
<b>Install the required depencies
```
$ cd CDNRECON
$ pip install https://github.com/PaulSec/API-dnsdumpster.com/archive/master.zip --user
$ pip3 install -r requirements.txt
```
<b>Sample usage guide

```
$ python3 main.py example.com shodan-key
```
<b> For more in-depth usage info, supply the -h flag (python3 main.py -h).</b>
````
usage: main.py [-h] [--write] domain [shodan]

CDNRECON - A Content Delivery Network recon tool

positional arguments:
  domain      Domain to scan
  shodan      Your Shodan API key

options:
  -h, --help  show this help message and exit
  --write     Write results to a target.com-results.txt file
````

## How to get a Shodan API key
<b>1. Register an account at https://account.shodan.io/ (it's totally free).<br>
<b>2. Head over the to the "Account" page and see the "API key" field.<br>
  <img src="https://a.pomf.cat/nvdiap.png"></img>
  
## To do
- Add more CDNs
- Add Censys support
- Add certificate search
- Add IPv4 range bruteforcer
- Add favicon hash search
- Add html body hash search
