# TCP Client Implementation
#
#
# Licence: GPLv3
# if this script is run as a module, ie: "python tcpClient.py" then
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
### TCPClient ###
#    TODO: * Remove\Reduce non-blocking functions in test mode and in TCPClient class
#	   * Change all referances to variable aInterface to something more clear that this
#	   * is a server we want to connect to. Perhaps aServerAddress
#          * Make CreateSocket create different types of TCP socket in TCPClient.CreateSocket
# 	   * Add code to detect when a client/Client is disconnected
# 	   * Add code/classes to allow and keep track of multiple connections
#	   * Add code/classes to make the Client Treadable
#	   * add a common connection handshake and a protocol and messaging stack
#	   * Add Exception handling where needed to handle errors better
#          * Test different methods of sending and recieving data
#    BUGS: * because right now we don't detect when a client disconnects, we are
#	     unable to detect that we should close our side down too and get ready
#	     to let other connections connect. As a result, if a client/Client is disconnected
#	     from the Client (ie: internet drops) then the client Client is locked up
#            waiting for data from the client to send data that will never come. Other
#	     clients can't to the Client atm, and the client bugs out. meh. 
#	   * its set in the main loop for the test code to exit on 'q', but it
#	   * doesn't. Killing the client in an improper fashion could lead to the Client
#	     locking up. 

''' Usage instructions: TCPClient

	aClient = TCPClient()
        aClient.CreateSocket()
	aClient.Connect(aInterface, aPort)
    	while 1:
		RecievedData - aClient.RecieveData(BufferSize)
		aClient.SendData(SomeData)
	aClient.Close

	First, we need to create an instance of TCPClient.
	We need to tell TCPClient something about our connection
	We give it the following information (or if left out, defaults are applied)
		#aInterface - destination to connect to
		#aPort to use
		#RecieveBufferSize - the max size of the recieve buffer
		#AutoInit - True or False
			   if you want to take care of creating the socket when we
			   we create the class.  Put True else
			   If we don't do this, then CreateSocket and Connect,will 
			   need to be called manually
			   
		Example Usage: - AutoInit example
	        create a connection on port 23 to another server
		# myClient = TCPClient('192.168.1.200', 23,512, True)
		Because we made AutoInit true, some of the work is taken
		care of for us (we don't need to call CreateSocket, connect)

		At this point we are now ready to begin reading/sending data

		Upon a connection taking place, the first thing we need to do
		is to enter our MainLoop() and see if the server sent anything
		to us when we connected, then send something back to the server
		so it knows we are connected, this can be a short message
		like so
		#	while i:
		#		KeyBoardInput = raw_input( 'Type something:')
		#		myClient.SendData (KeyBoardInput)
		or
		#	ON_CONNECT_MESSAGE = 'HELLO'
		#	while i:
		#		MyClient.SendData(ON_CONNECT_MESSAGE)

		close the socket when we are done with the MainLoop()
		# myClient.Close() 
		'''
class TCPClient():
	def __init__(self, aInterface = '', aPort = 6669, RecieveBufferSize = 512, AutoInit = False):
		# initialize everything we will need	
		PDebug("Initiliing class now")
		self.aInterface = aInterface
		self.aPort = aPort
		self.RecieveBufferSize = RecieveBufferSize
		PDebug("Class Data:")
		PDebug(('	aInterface: ', self.aInterface))
		PDebug(('	aPort: ', self.aPort))
		PDebug(('	RecieveBufferSize: ', self.RecieveBufferSize))

		# we don't need to save AutoInit, its only used in this function
		# self.AutoInit = AutoInit			
		if AutoInit == True:
			TempStr = "True"
		else:
			TempStr = "False"
		PDebug(('	AutoInit is set to ', TempStr))
		

		# check AutoInit, if true, we will take care of CreateSocket and Connect
		# otherwise, it will have to be done manuall
		if AutoInit == True:
			PDebug("Beginning AutoInit")
			CreateSocket()
			Connect(aInterface, aPort)
		PDebug("Init Finished")

	def CreateSocket(self):
		# Create our socket
		# TODO: Modify function defination and code to accept paramters for
		# socket so we can customize the type of socket made

		self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		PDebug(("SocketCreated: ", self.client_socket))

	def Connect(self,aInterface, aPort):
		PDebug(("Connect: ", aInterface, aPort))
		# Connect to server
		self.client_socket.connect((aInterface, aPort))
	
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
		# close socket
		self.client_socket.close()

def MainLoop():
	myClient = TCPClient()
	PDebug(("Created myClient Instance: ", myClient))
	
	myClient.CreateSocket()
	myClient.Connect(myClient.aInterface, myClient.aPort)
	
	while 1:
		PDebug("Entered Main Loop")
		PDebug("Now, call myClient.ReadData to begin waiting for data from Client")

		myClient.ReadData(myClient.RecieveBufferSize)

		PDebug(("Data Recieved from ", myClient.aInterface))
		PDebug(myClient.data)

		PDebug(("Asking user for data to send to Client at address ", myClient.aInterface))

		myClient.data = raw_input ("Enter Data:")

		PDebug(("Sending: ", myClient.data, " to ", myClient.aInterface))

		myClient.SendData(myClient.data)

		PDebug("Data sent")

		
		# why ain't this working? meh
		if myClient.data == "q": break
		if myClient.data == "Q": break

	myClient.Close()

# begin
if __name__ == '__main__':
	print __name__
	MainLoop()
