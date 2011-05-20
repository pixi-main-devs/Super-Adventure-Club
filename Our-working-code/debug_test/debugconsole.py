# Debug Console
#
# Usage: debugconsole.py -server to put into server mode
#        debugconsole.py -client <server ip> (test mode)
#
#   Console can be run in either Server mode or Client mode
#
#   In server mode, console listens for connections from a certain host
#   and outputs debugging information giving to it
#
#   In Client mode, console is included (imported) into whatever test
#   app we are making, as a class. The class is used to send the
#   debugging information back to the server. 
#
#   The server is standalone
#   The client requires to be part of another program
#
import server

class SSLDebugConsole:
	"""A simple implementation to test Cormacs socket stuff """

	# This is the Initialization routine. When the class is first
	# created in memory, ie: SomeVariable = SSLDebugConsole(aMode,aHostIp)
	# immediatly the code in __init__ is executed. This allows us to setup
	# some defaults depending on how we intend to use the class
	# This code is executed each time we make a brand new class but only
	# effects that class it is assigned to
	def __init__(self,aMode = '-client', aHostIp = ''):
		# Note: above, aMode = '-server', if nothing is passed here
		# then our Class will default to server (listen mode)
		# aMode must be one of two values, either -server or -client
		self.aMode = aMode # remember what mode we want to use to self
		print 'Executing __init__ in class SSLDebugConsole'
		print 'Setting aMode = ', aMode

		if aMode == '-client':
			print 'Setting aHostIp (client mode)'
			self.aHostIp = aHostIp 
		else:
			print 'Setting aHostIp (server mode)'
			self.aHostIp = '127.0.0.1'
		print 'aHostIp = ', aHostIp

			
	description = "Description of Class"
	author = "Ivan Malone"
	def GetMode(self):
		print 'GetMode called, return value will be ', self.aMode
		return self.aMode
	def GetHost(self):
		print 'GetHost called, return value will be ', self.aHostIp
		return self.aHostIp
	def GetInfo(self):
		print 'GetInfo called, return value will be ', self.description, self.author
		return (self.description, self.author);
	def StartServer(self):
		print 'Creating server instance'
		aServer = server.SSLServer(4444,'',4444)
		print 'Starting Server'
		aServer.CreateServer()
	
	
	
def main():
	# this is our main function, where code within the debug console
	# will begin execution from (but not when it is used as a class)
	#
	# Notice that first it creates SSLDebugConsole in a listen state(server)
	# Then creates another using the same class in client state.
	# The logic for both modes is decided in the __init__ method for
	# the SSLDebugConsole class


	print 'Creating Debug Console: '
	print '----------------------'

	TheDebugConsole = SSLDebugConsole('-server','') # create an instance of it
	TheDebugConsole.StartServer()
		
	# print some info stored about the class
	print 'Info: ', TheDebugConsole.GetInfo()	
	print '----------------------'
	print 'Creating loopback Console:'
	print '----------------------'
	LoopBackConsole = SSLDebugConsole('-client','127.0.0.1') # create another instance
	print 'Info: ', LoopBackConsole.GetInfo()
	print '----------------------'
	print 'ok'


# Execture actually begins here, from here
# we will just call Main()
main()
