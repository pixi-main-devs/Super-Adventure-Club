rhost='127.0.0.1'
rport=4433

KEYFILE='certs/test.key'
CERTFILE='certs/test.pem'



import xmlrpclib
import ssl, sys



server = xmlrpclib.Server('https://localhost:4433')

c = ssl.wrap_socket(server, cert_reqs=ssl.CERT_REQUIRED, ssl_version=ssl.PROTOCOL_SSLv3, ca_certs='certs/test.pem')

c.connect((rhost, rport))


print server.add(1,2)
print server.div(10,4)

