import SimpleHTTPServer
import SocketServer
import tcpserver

class MyTCPHandler(SocketServer.BaseRequestHandler):
    """
    The RequestHandler class for our server.

    It is instantiated once per connection to the server, and must
    override the handle() method to implement communication to the
    client.
    """

    def handle(self):
        # self.request is the TCP socket connected to the client
        self.data = self.request.recv(1024).strip()
        print "%s wrote:" % self.client_address[0]
        print self.data
	print self.client_address[0]
        # just send back the same data, but upper-cased
        self.request.send(self.data.upper())

PORT = 8000

Handler = SimpleHTTPServer.SimpleHTTPRequestHandler

#Handler = MyTCPHandler;
httpd = SocketServer.TCPServer(("", PORT), Handler)

print "serving at port", PORT
httpd.serve_forever()
