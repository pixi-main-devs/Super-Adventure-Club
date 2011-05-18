import sys, os, socket, time
from ncrypt import *

print 'generating RSA key...'
rk = rsa.RSAKey()
rk.generate()

print 'building certificate'
c = x509.X509Certificate()
xn = x509.X509Name()
xn.addEntry( 'commonName', 'ks' )
c.setVersion( 3 )
c.setSerialNumber( 1 )
c.setSubject( xn )
c.setIssuer( xn )
c.setPublicKey( rk )
c.setNotBefore( 0 )
c.setNotAfter( int(time.time()) + 365*24*60*60 )
c.sign( rk, digest.DigestType('sha1') )

if err.peekError()[0] :
    print err.peekError()
    print err.getError()
    sys.exit( -1 )

dhParams = dh.DH()
print 'generating dh parameters..'
dhParams.generateParameters( 512, 2 )
print 'done generating dh parameters'

listenSock = socket.socket( socket.AF_INET, socket.SOCK_STREAM )
listenSock.bind( ('localhost',4433) )
listenSock.listen( 5 )
ctx = ssl.SSLContext( ssl.SSL_METHOD_SSLv23 )
print 'setting certificate'
ctx.setCertificate( c )
try :
    pass
except ssl.SSLLibraryError, e :
    print e
    print e.getError()
    print e.getNestedErrors()
    sys.exit( -1 )

print 'setting private key'
ctx.setPrivateKey( rk )
print 'enabling dh'
ctx.enableDH( dhParams )

def handleSSLError( func ) :
    try :
        func()
    except ssl.SSLLibraryError, sle :
        print sle.__class__, sle
        print sle.getError()
        print sle.getNestedErrors()
    except ssl.SSLError, se :
        print se.__class__, se

while 1 :
    (c,remoteAddr) = listenSock.accept()
    print 'received connection from:', remoteAddr
    sc = ssl.SSLConnection( ctx, c )
    def connLoop() :
        sc.accept()
        while 1 :
            s = sc.recv( 1024 )
            if not s :
                print 'connection shutdown'
                break
            sys.stdout.write( s )
            sys.stdout.flush()
    handleSSLError( connLoop )
    handleSSLError( sc.shutdown )
    c.close()
