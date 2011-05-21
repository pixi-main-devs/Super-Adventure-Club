from subprocess import call
from socket import socket
import ssl, sys
rhost = "cor-laptop"
rport = 4444

def sendmessage(data):
   s = socket()
   c = ssl.wrap_socket(s, cert_reqs=ssl.CERT_REQUIRED,
                       ssl_version=ssl.PROTOCOL_SSLv3, ca_certs='server.pem')
   c.connect((rhost, rport))
   # naive and incomplete check to see if cert matches host
   #print c.getpeercert()
   c.write(data)
   response = c.read()
   print response
#   print 'error'
   c.close()

while 1:
#   print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
#   clear()
#   sys.cls()
#   input = raw_input("**************************************************\n\nsav   --followed by string will save the string remotely\nprt   --will print the last saved string\ntxt   --the following string is to be displayed on the remote side\ndta   --begin a file transfer and choose a file (reletive path required\ncmd   --followed by a command be executed on the remote node and out printed on screen\n\n(q to Quit)\n\n************************************************************************************\n\n>>")
   input = raw_input("""c:""")
   if input == 'exit':
      print 'killed, err, terminal'
      break
   if input =="":
      sendmessage('blk')
   else:
      data = input
      sendmessage(data)


