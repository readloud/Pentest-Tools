#!/usr/bin/env python3

import argparse
import urllib.parse
import urllib3
import requests
import queue
import re
from bs4 import BeautifulSoup

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class Crawler:

    def __init__(self, url):
        self.url = url

        parts = urllib.parse.urlparse(url)
        if not parts.scheme and not parts.netloc and parts.path:
            self.domain = parts.path
            self.url = parts._replace(scheme="http", netloc=parts.path, path="").geturl()
            self.scheme = "http"
        else:
            self.domain = parts.netloc
            self.scheme = "http" if not parts.scheme else parts.scheme

        self.user_agent = "WebCrawler/1.0"
        self.cookies = {}
        self.proxy = None

        # 
        self.queue = queue.Queue()
        self.visited = set()
        self.out_of_scope = set()
        self.resources = set()
        self.pages = set()
    
    def request(self, url):
        headers = { "User-Agent": self.user_agent }
        kwargs = { "verify": False, "cookies": self.cookies, "headers": headers }
        if self.proxy:
            kwargs["proxy"] = {
                "http": self.proxy,
                "https": self.proxy
            }
        
        print("requesting:", url)
        return requests.get(url, **kwargs)

    def start(self):

        self.queue.put(self.url)
        while not self.queue.empty():
            url = self.queue.get()
            if url in self.visited:
                continue

            self.visited.add(url)
            res = self.request(url)
            content_type = res.headers.get("Content-Type", None)
            if "text/html" not in content_type.lower().split(";"):
                continue

            urls = self.collect_urls(res.text)
            for url in urls:
                parts = urllib.parse.urlparse(url)
                if parts.netloc and parts.netloc != self.domain:
                    self.out_of_scope.add(url)
                else:
                    resources_ext = ["jpg", "jpeg", "gif", "png", "css", "js","svg","ico"]
                    path, args = parts.path, None
                    if "?" in path:
                        path = path[0:path.index("?")]
                        args = urllib.parse.parse_args(path[path.index("?")+1:])
                    if path.rsplit(".", 1)[-1] in resources_ext:
                        self.resources.add(url)
                    else:
                        self.pages.add(url)
                        self.queue.put(parts._replace(netloc=self.domain, scheme=self.scheme,fragment="").geturl())

    def collect_urls(self, page):
        soup = BeautifulSoup(page, "html.parser")

        urls = set()
        attrs = ["src","href","action"]
        tags = ["a","link","script","img","form"]

        for tag in tags:
            for e in soup.find_all(tag):
                for attr in attrs:
                    if e.has_attr(attr):
                        urls.add(e[attr])

        return urls


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("url", help="The target URI to scan to, e.g. http://example.com:8080/dir/")
    parser.add_argument("--proxy", help="Proxy to connect through") # TODO
    parser.add_argument("--user-agent", help="User-Agent to use")
    parser.add_argument("--cookie", help="Cookies to send", action='append', default=[])
    parser.add_argument('--verbose', '-v', help="Verbose otuput", action='store_true')

    args = parser.parse_args()

    crawler = Crawler(args.url)
    if args.user_agent:
        crawler.user_agent = args.user_agent
    if args.proxy:
        crawler.proxy = proxy

    cookie_pattern = re.compile("^([a-zA-Z0-9.%/+_-]+)=([a-zA-Z0-9.%/+_-])*$")
    for cookie in crawler.cookies:
        m = cookie_pattern.match(cookie)
        if not m:
            print("[-] Cookie does not match pattern:", cookie)
            print("[-] You might need to URL-encode it")
            exit()
        key, value = (urllib.parse.unquoute(m[1]),urllib.parse.unquoute(m[2]))
        crawler.cookies[key] = value

    crawler.start()

    results = { 
        "Pages": crawler.pages, 
        "Resources": crawler.resources,
        "Out of Scope": crawler.out_of_scope
    }

    for name, values in results.items():
        print(f"=== {name} ===")
        print("\n".join(values))
