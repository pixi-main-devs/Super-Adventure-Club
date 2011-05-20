from subprocess import Popen, PIPE


class ShellExec():
	def __init__(self,aCommand,Paramaters = ''):
		if Paramaters == '':
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
	
main();
