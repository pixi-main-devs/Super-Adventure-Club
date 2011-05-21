from shellmisc import ShellExec
import socket, ssl, os
lport = 4444
rhost = ""
rport = 4444
column1 = 0
column2 = 0
try:
#   bindsocket.close()
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
#   print newsocket
#   print fromaddr
   readdata = c.read()
   column1 = readdata[0:4]
   column2 = readdata[4:]
#testing stuff
#   print ("column1 is "+column1+". and column2 is "+column2)
#   cmdanargs = column2.split(' ')
#   for index, item in enumerate(cmdanargs):
#     print index, item

#blank responder
#   if "" in column1:
#      c.write("ok")

   if "sav" in column1:
#      print ("message saved to datafile!\n"+ column2)
      datafile = open('ssl.datafile', 'a')
      datafile.write(column2+"\n")
      datafile.close()
      c.write("message saved!")
      c.close()

   if "qit" in column1:
      print "Quit command recieved from remote peer."
      c.write("server stopped")
      c.close()
      bindsocket.close()
      break

   if "prt" in column1:
      datafile = open('ssl.datafile','r')
      prntfromfile = datafile.readlines()
      c.write(str(prntfromfile))
      c.close()

   if "dta" in column1:
      filename = column2.split(',')
#      print filename[0]
#      print filename[1]
      savefile = open(filename[0],'w')
      savefile.write(c.read())
      response = str(filename[0]+" has been saved")
      c.write(response)
      c.close()

   if "txt" in column1:
      print (str(fromaddr[0])+" says> "+column2)
      c.write("message sent\n")
      c.close()

# Command reciever for remote node
   if "cmd" in column1:
      cmds = column2.split(' ')
      print cmds
      aShell = ShellExec(cmds[0])
      shl = aShell.GetStdout()
#      print shl
      c.write(shl)
      c.close()

c.close()
bindsocket.close()
