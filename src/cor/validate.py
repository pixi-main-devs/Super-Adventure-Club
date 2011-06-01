import socket
import ssl

HOST = "www.google.com"
PORT = 443

# replace HOST name with IP, this should fail connection attempt,
# but it doesn't in Python 2.x
HOST = socket.getaddrinfo(HOST, PORT)[0][4][0]
print(HOST)

# create socket and connect to server
# server address is specified later in connect() method
sock = socket.socket()
sock.connect((HOST, PORT))

# wrap socket to add SSL support
sock = ssl.wrap_socket(sock,
  # flag that certificate from the other side of connection is required
  # and should be validated when wrapping 
  cert_reqs=ssl.CERT_REQUIRED,
  # file with root certificates
  ca_certs="cacerts.txt"
)
