from threadpool import ThreadPool
import time
import os
import sys 
import select 
import tty 
import termios

KBInput = " "
QUIT = False

def taskCallback(data):
	print "Callback called for thread with data: ", data

def print_something(data):
	print "test"
	return "test"

def read_keyboard(data):
#	KBInput = raw_input('input:')
#	return KBInput

	def isData():
        	return select.select([sys.stdin], [], [], 0) == ([sys.stdin], [], [])

	old_settings = termios.tcgetattr(sys.stdin)
	try:
	        tty.setcbreak(sys.stdin.fileno())

	        i = 0
	        while 1:
#        	        print i
                	i += 1

	                if isData():
        	                c = sys.stdin.read(1)
                	        if c == '\x1b':         # x1b is ESC
					return c
                        	        break
				else:
					KBInput == KBInput + c
					break
	finally:
        	termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)


print "Starting threads"
pool = ThreadPool(5)

# Insert tasks into the queue and let them run
pool.queueTask(read_keyboard, taskCallback)
pool.queueTask(print_something,taskCallback)


print "Entering Mainloop"
print "----------------"


while QUIT == False:
	pool.queueTask(read_keyboard,1, taskCallback)
	pool.queueTask(print_something,2, taskCallback)
	print KBInput
	if KBInput == "quit":
		QUIT = True
		pool.joinAll

	
print "----------------"
print "Exiting Mainloop"
