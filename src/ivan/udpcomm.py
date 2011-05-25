import socket
import threading
from handystuff import _const


# UDPSocket Class
# An Implementation for communication via UDP Sockets using Threading
# and Non-Blocking Asynchronous 
#
# We use simple udp sockets and messages to perform the basic roles of
# a Client or Server or to send/recieve Multicast messages. 
# 
# Inheriently UDP is neither client nor server and its connections are not
# persistent like TCP is. 
#
# Thus, in our implementation we add threading and an additional layer on
# top of UDP to take care of some basic communication and messaging tasks
#
# We try to hide the actual sockets implemention to something much more
# simple and we think in terms of making 'semi-persistent' but stable 
# connections between nodes that we can send data between.
#
# The UDPSocket can handle different roles
#   Client              In client mode we connect to a listening UDP socket
#   Server             We listen for connections from a UDP socket
#
# By design, a UDP socket is synchronous. This means that B cant do anything 
# until A has sent a message. Once A has sent and B has received, the opposite 
# occurs: A cant do anything until B has sent a message. 
# For a user program this isnt very intuitive, but it is good for "lower" level 
# communications. 
# To make an asynchronous connection, requires the use of two sockets. One
# to read and one to write. 


# Define some Defaults

class UDPSocket( threading.Thread ):
    def __init__(self, UDP_IP = '127.0.0.1',  UDP_PORT = '6669',  UDP_BUFFER = 1024):
        # Save Arguments
        self.UDP_IP = UDP_IP
        self.UDP_PORT = UDP_PORT
        self.UDP_BUFFER = UDP_BUFFER
    def Connect(self):    
        # Create our socket instance and put it in self
        self.socket = socket.socket( socket.AF_INET, socket.SOCK_DGRAM)
        return self.IsConnected
    def Disconnect(self):
        # do something
        self.socket.close()
        return self.IsConnected
    def SendData(self,  data):
        # do something
        self.socket.sendto( data ,  (self.UDP_IP,  self.UDP_PORT))
        Result = True; 
    def RecieveData(self):
        # do something
        return True
    def IsConnected(self):
        # do something
        return True
    



'''
# Server program

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
		print "\nReceived message '", data,"'"

# Close socket
UDPSock.close()

==========

# Client program

from socket import *

# Set the socket parameters
host = "localhost"
port = 21567
buf = 1024
addr = (host,port)

# Create socket
UDPSock = socket(AF_INET,SOCK_DGRAM)

def_msg = "===Enter message to send to server===";
print "\n",def_msg

# Send messages
while (1):
	data = raw_input('>> ')
	if not data:
		break
	else:
		if(UDPSock.sendto(data,addr)):
			print "Sending message '",data,"'....."

# Close socket
UDPSock.close()
'''
