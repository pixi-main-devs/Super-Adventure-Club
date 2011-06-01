from subprocess import Popen, PIPE
import shlex


# Shell Misc, anything to do with interacting with the shell or shortcuts to 
# making things either may appear in here
#
#



class ShellExec():
	'''ShellExec is a class that executes a shell command
	   and makes both Stdout and Stderr available from GetStdout 
	   and GetStderr'''

	# Initialization Method for the class
#	def __init__(self,aCommand,Paramaters):
	def __init__(self,aCommand):
#		print 'aCommand: ', aCommand
#		print 'Paramaters: ', Paramaters
#		if len (Paramaters) == 0:
#			print 'no params'			
#			(stdout,stderr) = Popen([aCommand], stdout=PIPE).communicate()
#			self.stdout = stdout
#			self.stderr = stderr
#		else:
			# called with command paramaters
			# Split our params into a list
#			print 'with params'
#			print Paramaters
		args = shlex.split(aCommand)
		print args
		(stdout,stderr) = Popen(args, stdout=PIPE).communicate()
		self.stdout = stdout
		self.stderr = stderr
	def GetStdout(self):
		return self.stdout
	def GetStderr(self):
		return self.stderr

def main():
	# Code for this module begins here for testing
	# 
		# 
	try:
		aShell = ShellExec('ps -a') # create our shell instance, pass it ls to run

		print aShell.GetStdout();

		if aShell.GetStderr() > 0:
			print 'Error: ', aShell.GetStderr()
	except:
		print 'Exception Raised'
		raise
	
if __name__ == '__main__': 
	main();
