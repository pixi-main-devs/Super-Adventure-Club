import socket               # Import socket module
from threadpool import ThreadPool
from SocketServer import BaseRequestHandler, TCPServer
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
 #  for t in connlst:
 #     print t
 #     t.send('hello to all')
 #  return True





def readsocket(sock):
   while 1:
      d = sock.recv(1024)
      print d
      sock.send('ok')
  #   return sock.recv(1024)






def acceptconnection(listensock):
   while 1:
      c ,addr = listensock.accept()
      print ("connection accepted "+ str(addr[0]))
#      addsockettolist(c)
      return c









pool = ThreadPool(5)
pool.queueTask(acceptconnection(s), addtosocketlist())
#c = acceptconnection(s)
while 1:
   try:
      for r in connlst:
         pool.queueTask(readsocket(r))
      
#      for w in connlst:
#         print w

   except:
      c.close()
      s.close()
