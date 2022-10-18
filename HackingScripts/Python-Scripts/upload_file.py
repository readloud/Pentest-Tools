#!/usr/bin/python

import sys
import os
import util

if len(sys.argv) < 2:
    print("Usage: %s <file> [port]" % sys.argv[0])
    exit(1)

# Create a TCP/IP socket
FILENAME = sys.argv[1]

# Bind the socket to the port or choose a random one
address = util.getAddress()
port = None if len(sys.argv) < 3 else int(sys.argv[2])
sock = util.openServer(address, port)
if not sock:
    exit(1)

print("Now listening, download file using:")
print('nc %s %d > %s' % (address, sock.getsockname()[1], os.path.basename(FILENAME)))
print()

while True:
    # Wait for a connection
    print('waiting for a connection')
    connection, client_address = sock.accept()

    try:
        print('connection from', client_address)

        with open(FILENAME, "rb") as f:
            content = f.read()
            connection.sendall(content)

    finally:
        # Clean up the connection
        connection.close()
