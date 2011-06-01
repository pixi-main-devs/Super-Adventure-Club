from socket import *
#import str
#from sys import *
#from os import *
lhost = ''
lport = 4445
sok = socket(AF_INET, SOCK_DGRAM)
sok.bind((lhost, lport))
hostlist = []
l = 0
i = 0
khfile = open('knownhosts', 'a')
khfile.close()
khfile = open('knownhosts', 'r')
hostlist = str.splitlines(khfile.read())


while 1:
   data,addr = sok.recvfrom(1024)
#   maintain knownhosts
   if addr[0] not in hostlist:
      openfile = open('knownhosts', 'w')
      hostlist.append(addr[0])
      for i in hostlist:
         print i
         openfile.write((i+'\n'))
      openfile.close()
#   else:
#      for i in hostlist:
#         print (str(i))
   
   
   print "data recieved from: ",addr
   print data
#   else:
#      pass   





