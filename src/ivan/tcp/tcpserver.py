# TCP server Implementation
#
# Authors: MorbidChimp
# Licence: GPLv3
# if this script is run as a module, ie: "python tcpserver.py" then
# debugging data will be printed to the screen
import socket

# in order to determine if we are been imported from another class
# or if we are been called directly by python we have to examine 
# the __name__ variable. 
#

# if __name__ is equal to '__main__' then we are been called by python
# if __name__ is anything else, then it is not
def PDebug(aData):
	if __name__ == '__main__':
		print 'Debug: ', aData
		return True
	else:
		return False



### TCPServer ###
#    TODO: * Remove\Reduce non-blocking functions in test mode and in TCPServer class
#          * Make CreateSocket create different types of TCP socket in TCPServer.CreateSocket
# 	   * Add code to detect when a client is disconnected
# 	   * Add code/classes to allow and keep track of multiple connections
#	   * Add code/classes to make the server Treadable
#	   * Create a TCPClient version of the class
#	   * add a connection handshake and a protocol and messaging stack
#	   * Add Exception handling where needed to handle errors better
#          * Test different methods of sending and recieving data
#    BUGS: * because right now we don't detect when a client disconnects, we are
#	     unable to detect that we should close our side down too and get ready
#	     to let other connections connect. As a result, if a client is disconnected
#	     from the server (ie: internet drops) then the client server is locked up
#            waiting for data from the client to send data that will never come. Other
#	     clients can't connect when this happens.
#	   * its set in the main loop for the test code to exit on 'q', but it
#	   * doesn't. Killing the client in an improper fashion could lead to
#	     the socket been unusable for a while, as its in use

''' Usage instructions: TCPServer

	aServer = TCPServer()
        aServer.CreateSocket()
	aServer.Bind(Interface, Port)
	aServer.Listen(ListenNum)
	aServer.Accept()
    	while 1:
		aServer.SendData(SomeData)
		RecievedData = aServer.RecieveData(BufferSize)
	aServer.Close

	First, we need to create an instance of TCPServer.
	We need to tell TCPServer something about our connection
	We give it the following information (or if left out, defaults are applied)
		#aInterface to bind to
		#aPort to use
		#ListenFor (still not sure what *exacty* this does
		#RecieveBufferSize - the max size of the recieve buffer
		#AutoInit - True or False
			   if you want to start SocketConnect, bind and listen
			   the moment we create the class.  Put True else
			   If we don't do this, then CreateSocket,Bind and Accept need 
			   to be called manually in code with the correct
			   values similiar to socket.bind(aInterface,aPort)
			   and socket.listen() and in the correct order

		Example Usage: - AutoInit example
	        create a listening server on port 23 accepting localonly connections
		# myServer - TCPServer('127.0.0.1', 23,5,512, True)
		Because we made AutoInit true, some of the work is taken
		care of for us (we don't need to call CreateSocket, bind and listen, 
		that is done for us in __init__

		At this point we are now ready to begin listening for connections
		we do this by calling myServer.Accept like so
		# myServer.Accept()
		At this point, code is blocked until a connection occors. Accept must 
		exist OUTSIDE and BEFORE entering the mainloop 	that handles the socket
		because accept is only needed to be called once per connection. 
		If we close the connection, we must call myServer.CreateSocket to
		recreate it again

		Upon a connection takes place, the first thing we need to do
		is to enter our MainLoop() and send something to the client
		so it knows we are connected, this can be a short message
		like so
		#	while i:
		#		KeyBoardInput = raw_input( 'Type something:')
		#		myServer.SendData (KeyBoardInput)
		or
		#	ON_CONNECT_MESSAGE = 'HELLO'
		#	while i:
		#		MyServer.SendData(ON_CONNECT_MESSAGE)
		Then, while still in our MainLoop() we need to begin waiting
		for data to be returned, this can be something in responce
		to a special commanded entered, like, HELLO, or it can
		be an aknowledgement of some kind, in this case, we will assume
		the client will aknowledge our connection with a predefined
		message, 'READY'. 
		If we send 'HELLO', and recieve back 'READY' we know that
		the connection is good and the client is ready to do something
		In this case, the correct responce to HELLO is READY. 
		#	ON_CONNECT_RESPONCE = 'READY'
		#	RECIEVE_BUFFER_SIZE = 512
		#	myServer.GetData(RECIEVE_BUFFER_SIZE)
		When we call MyServer.GetData code execution will again be
		blocked until the data is recieved or the buffer is filled.
		When that happens, code execution continues again and we
		can do something. In this example, we will check the responce
		and output it to screen
		#	if myServer.data == ON_CONNECT_RESPONCE:
				We Recieved the expected responce to HELLO
		#		print "Connection Excepted"
		#		print "We recieved: ", ON_CONNECT_RESPONCE
		#	else:
				The client did something we didn't expect
				so we can assume it is likely we are
				unable to talk to him because we are not
				"talking the same language" per say
		#		print "Connection Rejected"
				we need to close the socket to disconnect client
		#		myServer.Close()
				and because we closed it we need to create it again
		#		myServer.CreateSocket()
				and begin listening
		#		myServer.Listen(5)
				and again begin accepting connections
		#		myServer.Accept () #
				after Accept is called, ready to accept connections
				again
		close the socket when we are done with the MainLoop()
		# myServer.Close() 
		'''

class TCPServer():
	def __init__(self, aInterface = '', aPort = 6669, ListenFor = 5, RecieveBufferSize = 512, AutoInit = False):
		# initialize everything we will need
		PDebug("Initilizing class now")
		self.aInterface = aInterface
		self.aPort = aPort
		self.ListenFor = ListenFor
		self.RecieveBufferSize = RecieveBufferSize
		PDebug("Class Data: ")
		PDebug(('   aInterface: ', self.aInterface))
		PDebug(('   aPort: ', self.aPort))
		PDebug(('   ListenFor: ', self.ListenFor))
		PDebug(('   RecieveBufferSize: ', self.RecieveBufferSize))
		
		# we don't need to save AutoInit, its only used in this function
		# self.AutoInit = AutoInit
		if AutoInit == True:
			TempStr = "True"
		else:
			TempStr = "False"
		PDebug(('   AutoInit is set to ', TempStr))

		
		# check AutoInit, if true, we will take care of binding etc
		# otherwise, it will have to be done manually
		if AutoInit == True:
			# Auto Initialize our port and begin listening
			PDebug("Beginning AutoInit")
			CreateSocket()
			Bind(aInterface, aPort)
			Listen(ListenFor)
		PDebug( "Init finished")

	def CreateSocket(self):
		# Create our socket
		# TODO: Modify function defination and code to accept paramters for
		# socket so we can customize the type of socket made
		self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		PDebug(("SocketCreated: ", self.server_socket))


	def Bind(self, aInterface, aPort):
		PDebug(("Bind Called: ", aInterface, aPort))
		# Call our socket's Bind and pass it aInterface and aPort
		self.server_socket.bind((aInterface, aPort))
		return [aInterface, aPort]

		# TODO: Add exception handling for when its not possible to

		# bind to a server (ie: port in use)
	def Listen(self, ListenFor):
		# listen on socket
		PDebug(('Listen Called: ', ListenFor))
		self.server_socket.listen(ListenFor)
		self.ListenFor = ListenFor
		return ListenFor

	def Accept(self):
		# starts accepting connections
		PDebug("Accept Called")
		self.client_socket, self.address = self.server_socket.accept()
		PDebug(("Accepted for: ", self.client_socket, ' at address ', self.address))
		return self.client_socket

	def ReadData(self, SizeOfRecieveBuffer):
		# read data up to SizeOfRecieveBuffer
		PDebug(("ReadData Called: ", SizeOfRecieveBuffer))
                self.data = self.client_socket.recv(SizeOfRecieveBuffer)
		return self.data
		
	def SendData(self, DataToSend):
		# send data
		PDebug("SendData Called")
		self.client_socket.send (DataToSend)
		return DataToSend

	def Close(self):
		# close our socket
		PDebug("CloseSocket Called")
		self.client_socket.close()
		

def MainLoop():
	myServer = TCPServer()
	PDebug(("Created myServer Instance: ", myServer))
	
	myServer.CreateSocket()
	PDebug(('Binding to interface: ', myServer.aInterface, ' on port ', myServer.aPort))
	myServer.Bind(myServer.aInterface, myServer.aPort) # no blocking here

	PDebug(("Beginning Listen for ", myServer.ListenFor))
	myServer.Listen(myServer.ListenFor) # no blocking here either

	# Upon a connection been recieved, it now continues on
	# print "Incomming connection on: ", myServer.address
	myServer.Accept() # this is blocked
	# We dont go into the main loop until Accept releases
	# TODO: Find out if Non-blocking code will let us continue
	#	on  into the while loop without having to wait for
	#	a connection from client, then once in the while loop
	#	can we keep reading data until data is available, then 
	#	send reply?
	while 1:
		PDebug("Entered Main Loop")
		# further execution is blocked here until data is accepted
		# a connection is accepted, so we continue on execution
	
		# as a test, wait for input from keyboard and send that as data
		# to the client, because I'm using raw_input - execution is blocked
		# we store the data in myServer.data but it could be any variable
		PDebug(("Asking user for data to send to client at address ", myServer.address))
		myServer.data = raw_input ("Enter Data:")

		# send data to the client
		PDebug(("Sending: ", myServer.data, " to ", myServer.address))
		myServer.SendData(myServer.data)
		PDebug("Data sent")

		# Code will again be blocked here while ReadData is waiting for data
		PDebug("Now, call myServer.ReadData to begin waiting for data from client")
		myServer.ReadData(myServer.RecieveBufferSize)
	
		# now that we have data back from the client, we begin to do something with it
#		if myServer.data == 'q': break # exit
		
		PDebug(("Data Recieved from ", myServer.address))
		PDebug(myServer.data)
		
		if myServer.data == "q": break
		if myServer.data == "Q": break
		if myServer.data == "" : break
	# close our socket to release the port and stop accepting connections
	myServer.Close()



# execution begins here
# call mainloop
print __name__
MainLoop()
		
	

	
	

