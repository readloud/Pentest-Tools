#    __________  _   ______  ________________  _   __
#   / ____/ __ \/ | / / __ \/ ____/ ____/ __ \/ | / /
#  / /   / / / /  |/ / /_/ / __/ / /   / / / /  |/ / 
# / /___/ /_/ / /|  / _, _/ /___/ /___/ /_/ / /|  /  
# \____/_____/_/ |_/_/ |_/_____/\____/\____/_/ |_/   
#                                                     
# Created by @Juuso1337
# This program tries to find the origin IP address of a website protected by a reverse proxy
# Download the latest version from github.com/juuso1337/CDNRECON
# Version 0.9.5

############################################ All libraries required by this program
import sys                                            #
import os                                             #
if os.name == 'nt':                                   #
    WIN = True                                        #                                              
else:                                                 #
    WIN = False                                       #
    import pydig                                      #
from pyfiglet import Figlet                           # Render ASCII art
import requests                                       # Simple HTTP library
import socket                                         # Basic networking
import threading                                      # Threads
import argparse                                       # Parse commmand line arguments
import shodan                                         # IoT search engine
import time                                           # Time
from lists import *                                   # Separate file containing arrays
import random                                         # Random number generator
from colorama import Fore, Style                      # Make ANSII color codes work on Windows
from colorama import init as COLORAMA_INIT            # Colorama init
from dnsdumpster.DNSDumpsterAPI import DNSDumpsterAPI # Finds subdomains
#######################################################

PARSER = argparse.ArgumentParser(description = 'CDNRECON - A Content Delivery Network recon tool')

PARSER.add_argument('TARGET_DOMAIN', metavar ='domain', help ='Domain to scan')
PARSER.add_argument('SHODAN_API_KEY', metavar ='shodan', help ='Your Shodan API key', nargs='?')
PARSER.add_argument('--write', action='store_true', help="Write results to a target.com-results.txt file")

ARGS = PARSER.parse_args()

###################################### All command line arguments
TARGET_DOMAIN  = ARGS.TARGET_DOMAIN  #
SHODAN_API_KEY = ARGS.SHODAN_API_KEY #
WRITE          = ARGS.write          #
######################################

######################## Some global variables
VALID_SUBDOMAINS = []  # Valid subdomains get stored in this list
IP_ADDRESSES     = []  # Subdomain IP addresses get stored in this list
NOT_CLOUDFLARE   = []  # Non Cloudflare IP addresses get stored in this list
AKAMAI           = []  # Akamai IP addresses get stored in this list
########################

# Initialize colorama

COLORAMA_INIT(convert=True)

# Start of user-agent string list

USER_AGENT_STRINGS = [
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/37.0.2062.94 Chrome/37.0.2062.94 Safari/537.36",
    "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
    "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko",
    "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/600.8.9 (KHTML, like Gecko) Version/8.0.8 Safari/600.8.9",
    "Mozilla/5.0 (iPad; CPU OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) GSA/6.0.51363 Mobile/11D257 Safari/9537.53",
    "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36 LBBROWSER",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:37.0) Gecko/20100101 Firefox/37.0",
    "Mozilla/5.0 (Windows NT 6.2; ARM; Trident/7.0; Touch; rv:11.0; WPDesktop; Lumia 1520) like Gecko",
    "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.65 Safari/537.36",
    "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_6 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B651 Safari/9537.53"
]

# End of user-agent string list

##############################
#      Define functions      #
##############################

def IS_POINTING_TO_CF():

        if WIN == True:
            pass

        else:
            print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Checking {Fore.MAGENTA}{TARGET_DOMAIN}{Style.RESET_ALL} nameservers . . .")

            NS_RECORD = pydig.query(TARGET_DOMAIN, "NS")

            if  'cloudflare' in str(NS_RECORD):
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} {Fore.MAGENTA}{TARGET_DOMAIN}{Style.RESET_ALL} is pointing to Cloudflares nameservers")

            else:
                print(f"{Fore.RED}[-]{Style.RESET_ALL} {Fore.MAGENTA}{TARGET_DOMAIN}{Style.RESET_ALL} is not pointing to Cloudflares nameservers")
            
            print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Nameservers: {Fore.MAGENTA}{', '.join(NS_RECORD).replace('., ', ', ')[:-1]}{Style.RESET_ALL}")

def DNSDUMPSTER():

    try:
        RESPONSE = requests.get("https://dnsdumpster.com", verify=True)
        STATUS_CODE = RESPONSE.status_code
    
    except requests.exceptions.ConnectionError:
        print(f"{Fore.RED}[-]{Style.RESET_ALL} {Fore.MAGENTA}dnsdumpster.com{Style.RESET_ALL} seems to be down, skipping . . .")

    if STATUS_CODE != 200:
        print(f"{Fore.RED}[-]{Style.RESET_ALL} {Fore.MAGENTA}dnsdumpster.com{Style.RESET_ALL} seems to be down, skipping . . .")
    
    else:
        print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} DNSDumpster output for {Fore.BLUE}{TARGET_DOMAIN}{Style.RESET_ALL}")

        try:
            RESULTS = DNSDumpsterAPI().search(TARGET_DOMAIN)['dns_records']['host']

            for RESULT in RESULTS:

                RESULT_DOMAIN = RESULT['domain']

                try:
                    print(f"{Fore.CYAN}[+] {Style.RESET_ALL} {Fore.BLUE}{RESULT_DOMAIN}{Style.RESET_ALL} seems to be valid")
                    VALID_SUBDOMAINS.append(RESULT_DOMAIN)

                except:
                    pass

        except Exception as e:
                print(f"{e}")

def SUB_ENUM():

    print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Checking common subdomains . . .")

    for SUBDOMAIN in SUBDOMAINS:
        
        if SUBDOMAIN in VALID_SUBDOMAINS is not None:
            pass

        URL = f'http://{SUBDOMAIN}.{TARGET_DOMAIN}'      # Requests needs a valid HTTP(s) schema

        AGENT = random.choice(USER_AGENT_STRINGS)

        SUB_ENUM_AGENT = {

            'User-Agent': AGENT,
        }

        try:
            requests.get(URL, headers=SUB_ENUM_AGENT, timeout=5)

        except requests.ConnectionError:
            pass
        
        except requests.exceptions.Timeout:
            pass

        else:
            FINAL_URL = URL.replace("http://", "")       # (?) socket.gethostbyname doesn't like "http://"

            print(f"{Fore.CYAN}[+]{Style.RESET_ALL} {Fore.BLUE}{FINAL_URL}{Style.RESET_ALL} is a valid domain")

            if SUBDOMAIN in VALID_SUBDOMAINS is not None:
                pass
            else:
                VALID_SUBDOMAINS.append(FINAL_URL)

def SUB_IP():

     try:

        print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Getting subdomain IP addresses . . .")

        for SUBDOMAIN in VALID_SUBDOMAINS:

            SUBDOMAIN_IP = socket.gethostbyname(SUBDOMAIN)
            print(f"{Fore.CYAN}[+]{Style.RESET_ALL} {Fore.BLUE}{SUBDOMAIN}{Style.RESET_ALL} has an IP address of {Fore.BLUE}{SUBDOMAIN_IP}{Style.RESET_ALL}")

            if SUBDOMAIN_IP in IP_ADDRESSES is not None:
                pass
            else:
                IP_ADDRESSES.append(SUBDOMAIN_IP)

     except socket.gaierror as ge:
            print(f"{Fore.RED}[-]{Style.RESET_ALL} Temporary failure in name resolution")
            sys.exit()

def IS_CF_IP():

    for IP in IP_ADDRESSES:

            print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Checking if {Fore.BLUE}{IP}{Style.RESET_ALL} is Cloudflare . . .")

            AGENT = random.choice(USER_AGENT_STRINGS)

            IS_CF_AGENT = {
                'User-Agent': AGENT
            }

            try:
                HEAD = requests.head(f"http://{IP}", headers=IS_CF_AGENT, timeout=5)
                HEADERS = HEAD.headers
            
            except ConnectionError:
                print(f"{Fore.RED}[-]{Style.RESET_ALL} Couldn't connect to {Fore.BLUE}{IP}{Style.RESET_ALL}, skipping . . .")
            
            except requests.exceptions.ConnectTimeout:
                print(f"{Fore.RED}[-]{Style.RESET_ALL} Connection to {Fore.BLUE}{IP}{Style.RESET_ALL} timed out, skipping . . .")

            global IP_COUNTRY

            IP_COUNTRY = requests.get(f"http://ip-api.com/csv/{IP}?fields=country").text.strip()
            
            if 'CF-ray' in HEADERS is not None:

                CLOUDFLARE = True

                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} {Fore.CYAN}{IP}{Style.RESET_ALL} is Cloudflare")
                RAY_ID = HEAD.headers['CF-ray']
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Ray-ID: {Fore.CYAN}{RAY_ID}{Style.RESET_ALL}")
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Country: {IP_COUNTRY}")

            if 'CF-ray' not in HEADERS:
                print(f"{Fore.GREEN}[!]{Style.RESET_ALL} {Fore.RED}{IP}{Style.RESET_ALL} is NOT cloudflare")

                if IP in NOT_CLOUDFLARE is not None:
                    pass
                else:
                    NOT_CLOUDFLARE.append(IP)

def IS_AKAMAI():

    IS_AKAMAI = False

    for IP in NOT_CLOUDFLARE:

        print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Checking if {Fore.BLUE}{IP}{Style.RESET_ALL} is Akamai . . .")

        IS_AKAMAI_AGENT = random.choice(USER_AGENT_STRINGS)
        
        AKAMAI_USER_AGENT = {
            'User-Agent': IS_AKAMAI_AGENT
        }

        try:
            HEAD = requests.head(f"http://{IP}", headers=AKAMAI_USER_AGENT)
            HEADERS = HEAD.headers
        
        except ConnectionError:
            print(f"{Fore.RED}[-]{Style.RESET_ALL} Couldn't connect to {Fore.BLUE}{IP}{Style.RESET_ALL}, skipping . . .")

        except requests.exceptions.ConnectTimeout:
            print(f"{Fore.RED}[-]{Style.RESET_ALL} Connection to {Fore.BLUE}{IP}{Style.RESET_ALL} timed out, skipping . . .")

        if 'x-akamai' in HEADERS is not None:

                IS_AKAMAI = True

                AKAMAI.append(IP)

                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} {Fore.CYAN}{IP}{Style.RESET_ALL} is Akamai")
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Country: {IP_COUNTRY}")
        
        if 'Server' in HEADERS is not None:
            
            SERVER = HEADERS['Server']

            if 'AkamaiGHost' in SERVER is not None:

                    IS_AKAMAI = True

                    AKAMAI.append(IP)

                    print(f"{Fore.CYAN}[+]{Style.RESET_ALL} {Fore.CYAN}{IP}{Style.RESET_ALL} Server detected as {Fore.GREEN}AkamaiGHost{Style.RESET_ALL}")
                    print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Country: {IP_COUNTRY}")
        
        if IS_AKAMAI == False:

            print(f"{Fore.GREEN}[!]{Style.RESET_ALL} {Fore.RED}{IP}{Style.RESET_ALL} is NOT Akamai")

def CHECK_TLDS():

    HEAD, SEP, TAIL = TARGET_DOMAIN.partition('.')

    for TLD in TLDS:

        URL = f"http://{HEAD}.{TLD}"

        try:
            NEW_DOM = requests.get(URL)

        except requests.ConnectionError:
            pass

        else:
            FINAL_URL = URL.replace("http://", "")
            print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Possible TLD found: {Fore.BLUE}{FINAL_URL}{Style.RESET_ALL}")


def SHODAN_LOOKUP():

    if not NOT_CLOUDFLARE:
        print(f"{Fore.RED}[-]{Style.RESET_ALL} No leaked IP addresses found\n")
        sys.exit()

    try:
        API = shodan.Shodan(SHODAN_API_KEY)

        for IP in NOT_CLOUDFLARE:

            print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Shodan results for {Fore.BLUE}{IP}{Style.RESET_ALL}")

            RESULTS = API.host(IP)
            COUNTRY = RESULTS["country_name"]
            ISP = RESULTS['isp']
            HOSTNAME = RESULTS['hostnames']
            DOMAINS = RESULTS['domains']
            PORTS = RESULTS['ports']
            OS = RESULTS['os']

            NONE = True

            if ISP is not None:       
                NONE = False
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} ISP: {Fore.BLUE}{ISP}{Style.RESET_ALL}")
            
            if COUNTRY is not None:
                NONE = False
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Country: {Fore.BLUE}{COUNTRY}{Style.RESET_ALL}")
            
            if HOSTNAME is not None:
                NONE = False
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Hostname(s): {Fore.BLUE}{HOSTNAME}{Style.RESET_ALL}")
            
            if DOMAINS is not None:
                NONE = False
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Domain(s): {Fore.BLUE}{DOMAINS}{Style.RESET_ALL}")
            
            if PORTS is not None:
                NONE = False
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Open port(s): {Fore.BLUE}{PORTS}{Style.RESET_ALL}")

            if OS is not None:
                NONE = False
                print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Operating system: {Fore.BLUE}{OS}{Style.RESET_ALL}")
            
            if NONE == True:
                print(f"{Fore.RED}[-]{Style.RESET_ALL} No results for {Fore.BLUE}{IP}{Style.RESET_ALL}")

    except shodan.APIError as api_error:
        print(f"{Fore.RED}[-]{Style.RESET_ALL} No shodan API key supplied or the key is invalid")

def SEPARATOR():

    print(f"{Fore.YELLOW}={Style.RESET_ALL}" * 50)

def THREAD(FUNCTION):

    SEPARATOR()
    THREAD = threading.Thread(target=FUNCTION)
    THREAD.start()
    THREAD.join()
      
def MAIN():

        try:

            START_TIME = time.perf_counter()

            ASCII = Figlet(font='slant', width=100)
            ASCII_RENDER = ASCII.renderText("CDNRECON")
            print (f"{Fore.YELLOW}{ASCII_RENDER}")

            IS_POINTING_TO_CF()
            THREAD(DNSDUMPSTER)
            THREAD(SUB_ENUM)
            THREAD(SUB_IP)
            THREAD(IS_CF_IP)
            THREAD(IS_AKAMAI)
            THREAD(SHODAN_LOOKUP)
    
            if WRITE == True:

                with open(f"{TARGET_DOMAIN}-results.txt", "w") as FILE:

                    for SUBDOMAIN in VALID_SUBDOMAINS:
                            FILE.write(f"VALID SUBDOMAIN: {SUBDOMAIN}\n")

                    for IP in NOT_CLOUDFLARE:
                            FILE.write(f"LEAKED IP: {IP}\n")
                    
                    print(f"{Fore.CYAN}[+]{Style.RESET_ALL} Saved results in {Fore.BLUE}{TARGET_DOMAIN}-results.txt{Style.RESET_ALL}")

            PERF = (time.perf_counter() - START_TIME)
            TOOK = int(PERF)

            print(f"{Fore.MAGENTA}[i]{Style.RESET_ALL} Finished in {TOOK} seconds")

        except KeyboardInterrupt:
            print("[i] Keyboard interrupt detected, exiting...")

        except Exception as e:
            print(f"[-] Exception occured\n--> {e}")

if __name__ == "__main__":
        MAIN()

##############################
#      End of program        #
##############################