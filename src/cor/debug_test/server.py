import socket, ssl, os


class SSLServer:
	"""A simple SSL Server"""
	def __init__(self,LocalPort = 4444, RemoteHost = '127.0.0.1',RemotePort = 4444):
		self.LocalPort = LocalPort
		self.RemoteHost = RemoteHost
		self.RemotePort = RemotePort
		c = ssl.wrap_socket(newsocket, server_side=True, certfile="server.pem",keyfile="server.key", ssl_version=ssl.PROTOCOL_SSLv3)
		

	def CreateServer(self):
		print 'creating socket'
		self.bindsocket = socket.socket()
		print 'binding on all interfaces to localport: ' , self.LocalPort
		self.bindsocket.bind(('',self.LocalPort))
		print 'listening(5)'
		self.bindsocket.listen(5) # what does 5 mean here?
		print 'beginning loop'
		i = 0;
		while i:
			NewSocket, selfFromAddr = bindsocket.accept()
			c = ssl.wrap_socket(newsocket, server_side=True, certfile="server.pem",keyfile="server.key", ssl_version=ssl.PROTOCOL_SSLv3)
			readdata = c.read()
			column1 = readdata[0:4]
			column2 = readdata[4:]
			## PROCESS DATA HERE

			## END
		print 'exiting loop'
		print 'closing socket'
		self.c.close()
		print 'closing binding'
		self.bindsocket.close()
		
	
		
		
