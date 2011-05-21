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
         return True
      except :
         return False



   def ReadFromSocket(self):
      self.data = self.c.read()
      return  self.data


   def WriteToSocket(self,data):
      try:
         self.c.write(data)
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
      if self.CreateSocket() == True:
         readdata = self.ReadFromSocket()
         print readdata
         return True
      else:   
         print "socket creation failed"
         return False
          
     
if __name__ == '__main__':
   sslear = SSLlistener()
   sslear.StartupServer()
   while 1:
      while sslear.ReadFromSocket() != '':
         print(sslear.data)

