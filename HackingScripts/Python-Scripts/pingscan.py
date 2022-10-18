#!/usr/bin/python

import sys
import os
import ipaddress
import subprocess

try:
    import threading
    import queue
    NUM_THREADS = 10
    THREADING_ENABLED = True
    QUEUE = queue.Queue()
except:
    THREADING_ENABLED = False
    
def checkHost(host):
    proc = subprocess.Popen(["ping", str(host), "-c", "1"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return proc.wait() == 0

def doWork(q):
    while not q.empty():
        host = q.get()
        if checkHost(host):
            print("[+] Host %s is online" % host)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: %s <hosts>" % sys.argv[0])
        exit(1)

    hosts = sys.argv[1]
    if "/" not in hosts:
        if checkHost(hosts):
            print("[+] Host %s is online" % hosts)
        else:
            print("[-] Host %s is not reachable" % hosts)
    else:
        cidr = ipaddress.ip_network(hosts)
        hosts = list(cidr.hosts())
        if not THREADING_ENABLED:
            print("Scanning %d hosts in range: %s..." % (len(hosts), cidr))
            for host in hosts:
                if checkHost(host):
                    print("[+] Host %s is online" % host)
            print("Done")
        else:
            print("Scanning %d hosts in range: %s with %d threads..." % (len(hosts), cidr, NUM_THREADS))
            for host in hosts:
                QUEUE.put(host)

            threads = []
            for i in range(NUM_THREADS):
                t = threading.Thread(target=doWork, args=(QUEUE, ))
                t.start()
                threads.append(t)

            for t in threads:
                t.join()
            print("Done")
