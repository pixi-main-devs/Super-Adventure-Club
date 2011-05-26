import socket               # Import socket module
import thread


s = socket.socket()         # Create a socket object
host = socket.gethostname() # Get local machine name
port = 12345         
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((host, port))        # Bind to the port
s.listen(5)                 # Now wait for client connection.

connlst = []
i = 0


def addsockettolist(sock):
   numcon = len(connlst)
   connlst.insert(numcon,sock)
   for t in connlst:
      print t
      t.send('hello to all')
   return True

def readsocket(sock):
   d = sock.recv(1024)
   print d
   sock.send('ok')
   return sock.recv(1024)

def acceptconnection(listensock):
   while 1:
      c ,addr = listensock.accept()
      addsockettolist(c)
      return c


c = acceptconnection(s)
while 1:
   try:
      for r in connlst:
         readsocket(r)
#      for w in connlst:
#         print w

   except:
      c.close()
      s.close()
