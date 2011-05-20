import socket, ssl, os
lport = 4444
rhost = ""
rport = 4444
bindsocket = socket.socket()
bindsocket.bind(('', lport))
bindsocket.listen(5)
while 1:
   newsocket, fromaddr = bindsocket.accept()
   c = ssl.wrap_socket(newsocket, server_side=True, certfile="server.pem",
                    keyfile="server.key", ssl_version=ssl.PROTOCOL_SSLv3)
   readdata = c.read()
   column1 = readdata[0:4]
   column2 = readdata[4:]
   print ("column1 is "+column1+". and column2 is "+column2)
   if "save" in column1:
      print ("message saved to datafile!\n"+ column2)
      datafile = open('ssl.datafile', 'a')
      datafile.write(column2+"\n")
      datafile.close()
   if "quit" in column1:
      print "Quit command recieved from remote peer."
      break
   if "prnt" in column1:
      datafile = open('ssl.datafile','r')
      prntfromfile = datafile.readline()
      print prntfromfile
#   else:
#      print "message not recieved"
#      break
#c.write('200 OK\r\n\r\n')
c.close()
bindsocket.close()
