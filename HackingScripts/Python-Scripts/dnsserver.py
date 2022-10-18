#!/usr/bin/env python
# coding=utf-8

import argparse
import datetime
import sys
import time
import threading
import traceback
import socketserver
import struct

try:
    from dnslib import *
except ImportError:
    print("Missing dependency dnslib: <https://pypi.python.org/pypi/dnslib>. Please install it with `pip`.")
    sys.exit(2)


class DnsServer:

    class BaseRequestHandler(socketserver.BaseRequestHandler):

        def get_data(self):
            raise NotImplementedError

        def send_data(self, data):
            raise NotImplementedError

        def handle(self):
            now = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')
            try:
                data = self.get_data()
                self.send_data(self.server.server.dns_response(data))
            except Exception:
                traceback.print_exc(file=sys.stderr)

    class TCPReqImpl(BaseRequestHandler):

        def get_data(self):
            data = self.request.recv(8192).strip()
            sz = struct.unpack('>H', data[:2])[0]
            if sz < len(data) - 2:
                raise Exception("Wrong size of TCP packet")
            elif sz > len(data) - 2:
                raise Exception("Too big TCP packet")
            return data[2:]

        def send_data(self, data):
            sz = struct.pack('>H', len(data))
            return self.request.sendall(sz + data)

    class UDPReqImpl(BaseRequestHandler):

        def get_data(self):
            return self.request[0].strip()

        def send_data(self, data):
            return self.request[1].sendto(data, self.client_address)

    class UDPImpl(socketserver.ThreadingUDPServer):

        def __init__(self, server):
            super().__init__((server.bind_addr, server.listen_port), DnsServer.UDPReqImpl)
            self.server = server

    class TCPImpl(socketserver.ThreadingTCPServer):

        def __init__(self, server):
            super().__init__((server.bind_addr, server.listen_port), DnsServer.TCPReqImpl)
            self.server = server

    def __init__(self, addr, port=53):
        self.bind_addr = addr
        self.listen_port = port
        self.sockets = []
        self.threads = []
        self.sockets.append(DnsServer.UDPImpl(self))
        self.sockets.append(DnsServer.TCPImpl(self))
        self.entries = { "A": {}, "AAAA": {}, "MX": {}, "TXT": {}, "NS": {} }
        self.debug = False
        self.ttl = 60 * 5
        self.logging = False

    def addEntry(self, type, domain, value):
        if type not in self.entries:
            print("Invalid type, must be one of:", self.entries.keys())
            return False

        if not domain.endswith("."):
            domain += "."

        if type in ["A","MX","NS"]:
            value = A(value)
        elif type in ["AAAA"]:
            value = AAAA(value)
        elif type in ["TXT"]:
            value = CNAME(value)

        if self.debug:
            print(f"Added entry: {type} {domain} => {value}")

        self.entries[type][domain] = value
        return True

    def startBackground(self):
        for socket in self.sockets:
            t = threading.Thread(target=socket.serve_forever)
            t.start()
            self.threads.append(t)

    def start(self):
        self.startBackground()
        map(lambda t: t.join(), self.threads)

    def stop(self):
        map(lambda s: s.shutdown(), self.sockets)
        map(lambda t: t.join(), self.threads)

    def dns_response(self, data):
        request = DNSRecord.parse(data)

        if self.debug:
            print("DNS REQUEST:", request)

        reply = DNSRecord(DNSHeader(id=request.header.id, qr=1, aa=1, ra=1), q=request.q)
        qname = request.q.qname
        qn = str(qname)
        qtype = request.q.qtype
        qt = QTYPE[qtype]

        if qt in self.entries and qn in self.entries[qt]:
            entry = self.entries[qt][qn]
            rqt = entry.__class__.__name__
            reply.add_answer(RR(rname=qname, rtype=getattr(QTYPE, rqt), rclass=1, ttl=self.ttl, rdata=entry))
            if self.logging:
                print(f"Request: {qt} {qn} -> {entry}")

        if self.debug:
            print("DNS RESPONSE:", reply)

        return reply.pack()
