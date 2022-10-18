#!/usr/bin/env python3

import requests
import sys
from bs4 import BeautifulSoup

def analyze(soup):
    tables = soup.find_all("table")
    for table in tables:
        thead = table.find("tr", { "class": "h" })
        if not thead or len(thead.find_all("th")) != 3:
            continue

        for tr in table.find_all("tr"):
            tds = tr.find_all("td")
            if len(tds) != 3:
                continue

            label, local, master = tds       
            if local.text != master.text:
                print(f"[+] {label.text} differs. local={local.text} master={master.text}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: %s <url>", sys.argv[0])
    else:
        url = sys.argv[1]
        res = requests.get(url)
        if res.status_code != 200:
            print("[-] Server returned:", res.status_code, res.reason)
        else:
            soup = BeautifulSoup(res.text, "html.parser")
            analyze(soup)
