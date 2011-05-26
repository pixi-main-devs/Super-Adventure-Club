import socket               # Import socket module

s = socket.socket()         # Create a socket object
host = socket.gethostname() # Get local machine name
port = 12345                # Reserve a port for your service.

s.connect((host, port))
while 1:
   print s.recv(1024)
   print "socket type = "+str(s.type)
   print "socket proto = "+str(s.proto)
   print "socket family = "+str(s.family)
   input = raw_input("""Enter data to send (Type 'q' to exit client app):>""" )
   if 'q' == input:
      break
   s.send(input)
s.close                     # Close the socket when done

