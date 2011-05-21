from subprocess import Popen, PIPE

# Shell Misc, anything to do with interacting with the shell or shortcuts to 
# making things either may appear in here
#
#


class ShellExec():
	'''ShellExec is a class that executes a shell command
	   and makes both Stdout and Stderr available from GetStdout 
	   and GetStderr'''

	# Initialization Method for the class
	def __init__(self,aCommand,Paramaters = []):
		if not Paramaters:
			(stdout,stderr) = Popen([aCommand], stdout=PIPE).communicate()
			self.stdout = stdout
			self.stderr = stderr
		else:
			(stdout,stderr) = Popen([aCommand,Paramaters], stdout=PIPE).communicate()
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
		aShell = ShellExec('ls') # create our shell instance, pass it ls to run
		print aShell.GetStdout();
		if aShell.GetStderr() > 0:
			print 'Error: ', aShell.GetStderr()
	except:
		print 'Exception Raised'
	
if __name__ == '__main__': main();
