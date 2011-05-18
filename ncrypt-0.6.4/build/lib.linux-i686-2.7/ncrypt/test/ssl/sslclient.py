import sys, os, socket
from ncrypt import *

ctx = ssl.SSLContext( ssl.SSL_METHOD_TLSv1 )

certFile = 'sreeram.cert'
c = x509.X509Certificate()
print 'loading certificate:', certFile
c.fromPEM( file(certFile).read() )

rk = rsa.RSAKey()
keyFile = 'sreeram.key'
print 'loading key:', keyFile
rk.fromPEM_PrivateKey( file(keyFile).read() )

ctx.setCertificate( c )
ctx.setPrivateKey( rk )
ctx.setVerifyMode( ssl.SSL_VERIFY_MODE_SELF_SIGNED )


a = ( 'localhost', 4433 )
s = socket.socket( socket.AF_INET, socket.SOCK_STREAM )
s.connect( a )
sc = ssl.SSLConnection( ctx, s )
sc.connect()
sc.send( 'Hello There\r\n' )
sc.shutdown()
s.close()
