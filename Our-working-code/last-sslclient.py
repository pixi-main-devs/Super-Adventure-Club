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
   print 'error'
   c.close()

while 1:
#   print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
#   clear()
#   sys.cls()
   input = raw_input("what message do you want to send\n\nsave  --followed by string will save the string remotely\nprnt  --will print the last saved string\ntext  --the following string is to be displayed on the remote side\n\n(q to Quit)")
   if input == 'q':
      break
   if input =="":
      break
   if input == 'data':
      return_code = call("ls -l", shell=True)
      inputfile = raw_input("please specify valid file to transfer?\n>")
      file = open (inputfile,'r')
      filedata = file.read()
      stringtosend= str(input+" "+inputfile+","+filedata)
      sendmessage(stringtosend)
   else:
      data = input
      sendmessage(data)


