from subprocess import Popen, PIPE
import shlex

class ShellExec():
	'''ShellExec is a class that executes a shell command
	   and makes both Stdout and Stderr available from GetStdout 
	   and GetStderr
       
       Known Issues:
            When passing more than one paramater to ShellExec that
            represent the arguments to be passed to the application
            we want to run, it seems bash doesn't inturpret either spaces
            correctly or the application is invisibly adding two "'s to the
            beginning and end of the entire string. 
            
            I've tried various ways of calling POpen, but not managed
            to solve the problem. However, if you arrange the code
            so that each paramater is passed one element at a time in
            list format, it seems to work grand. 
            
            Calling interactive applications can have problems (nano, vim)
            and we need to do some basic error checking, file exists etc'''

	def __init__(self,aCommand):
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
	# Test Code for this module begins here 
	try:
		aShell = ShellExec('ps -a') # create our shell instance, pass it ls to run
		print aShell.GetStdout();
		if aShell.GetStderr() > 0:
			print 'Error: ', aShell.GetStderr()
	except:
		print 'Exception Raised'
		raise # remove this here to halt raising it any further
	
if __name__ == '__main__': 
	main();

