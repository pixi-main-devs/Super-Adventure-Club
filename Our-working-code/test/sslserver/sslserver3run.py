import pytunnel,httplib

def tunnel_this(ip,port): 
	conn = httplib.HTTPSConnection(ip,port=port) 
	conn.putrequest('GET', '/') 
	conn.endheaders() 
	response = conn.getresponse() 
	print response.read()

tunnel=pytunnel.build(host='http://www.google.ie',proxy_host='h1', proxy_user='u',proxy_pass='p') 
tunnel.run(tunnel_this)
