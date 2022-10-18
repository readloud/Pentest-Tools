#!/usr/bin/python

import socket
import sys
import re

try:
    import threading
    import queue
    NUM_THREADS = 10
    THREADING_ENABLED = True
    QUEUE = queue.Queue()
except:
    THREADING_ENABLED = False

if len(sys.argv) < 2:
    print("Usage: %s <host> [ports] [num_threads]" % sys.argv[0])
    exit(1)

host = sys.argv[1]
ports = range(1,1001)

if len(sys.argv) >= 3:
    ports_param = sys.argv[2]
    pattern = re.compile("^(\\d+)(-(\\d+)?)?$")
    m = pattern.match(ports_param)
    if m is None:
        print("Invalid port range")
        exit(1)

    start_port = int(m.group(1))
    end_port = start_port
    if m.group(2) is not None:
        if m.group(3) is None:
            end_port = 65535
        else:
            end_port = int(m.group(3))

    if start_port < 1 or start_port > 65535:
        print("Invalid start port")
        exit(1)
    elif end_port < 1 or end_port > 65535:
        print("Invalid end port")
        exit(1)
    elif start_port > end_port:
        print("Invalid port range")
        exit(1)

    ports = range(start_port, end_port+1)

if len(sys.argv) >= 4:
    if not THREADING_ENABLED:
        print("Threading is not supported by this system, you need the libraries: threading, queue")
        exit(1)
    else:
        NUM_THREADS = int(sys.argv[3])
        if NUM_THREADS < 1:
            print("Invalid thread count:", NUM_THREADS)
            exit(1)

def tryConnect(host, port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3.0)
        sock.connect((host,port))
        sock.close()
        return True
    except Exception as e:
        return False

def doWork(q, host):
    while not q.empty():
        p = q.get()
        if tryConnect(host, p):
            print("[+] Port %d is open" % p)

if not THREADING_ENABLED:
    print("Scanning ports: %d-%d..." % (ports[0], ports[len(ports)-1]))
    open_ports = []
    for p in ports:
        if tryConnect(host, p):
            print("[+] Port %d is open" % p)
    print("Done")
else:
    print("Scanning ports: %d-%d with %d threads..." % (ports[0], ports[len(ports)-1], NUM_THREADS))
    for i in ports:
        QUEUE.put(i)

    threads = []
    for i in range(NUM_THREADS):
        t = threading.Thread(target=doWork, args=(QUEUE, host))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()
    print("Done")
