# Server program
from shellmisc import ShellExec
from socket import *

# Set the socket parameters
host = "localhost"
port = 21567
buf = 1024
addr = (host,port)

# Create socket and bind to address
UDPSock = socket(AF_INET,SOCK_DGRAM)
UDPSock.bind(addr)

# Receive messages
while 1:
	data,addr = UDPSock.recvfrom(buf)
	if not data:
		print "Client has exited!"
		break
	else:
		#print "\nReceived message '", data,"'"
		print addr, data
		aShell = ShellExec(data)
		print aShell.GetStdout()
		UDPSock.sendto(aShell.data,addr)

# Close socket
UDPSock.close()

