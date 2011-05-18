import sys, os, socket, time
from ncrypt import *

certFile = 'sreeram.cert'
c = x509.X509Certificate()
print 'loading certificate:', certFile
c.fromPEM( file(certFile).read() )

rk = rsa.RSAKey()
keyFile = 'sreeram.key'
print 'loading key:', keyFile
rk.fromPEM_PrivateKey( file(keyFile).read() )

dhParamsFile = 'dhparams.pem'
dhParams = dh.DH()
print 'loading dh params:', dhParamsFile
dhParams.fromPEM_Parameters( file(dhParamsFile).read() )

def handleSSLError( func, exceptFunc=None ) :
    try :
        func()
    except ssl.SSLLibraryError, sle :
        print sle.__class__, sle
        print sle.getError()
        print sle.getNestedErrors()
        if exceptFunc :
            exceptFunc()
    except ssl.SSLError, se :
        print se.__class__, se
        if exceptFunc :
            exceptFunc()

listenSock = socket.socket( socket.AF_INET, socket.SOCK_STREAM )
listenSock.bind( ('localhost',4433) )
listenSock.listen( 5 )
ctx = ssl.SSLContext( ssl.SSL_METHOD_SSLv23 )
def initCtx() :
    print 'setting certificate'
    ctx.setCertificate( c )
    print 'setting private key'
    ctx.setPrivateKey( rk )
    ctx.setVerifyMode( ssl.SSL_VERIFY_MODE_SELF_SIGNED )
    print 'enabling dh'
    ctx.enableDH( dhParams )
handleSSLError( initCtx, lambda : sys.exit(-1) )

while 1 :
    (c,remoteAddr) = listenSock.accept()
    print 'received connection from:', remoteAddr
    sc = ssl.SSLConnection( ctx, c )
    def connLoop() :
        sc.accept()
        print 'verify result =', sc.getVerifyResult()
        try :
            clientCert = sc.getPeerCertificate()
            print 'peer certificate present'
        except ssl.SSLError, se :
            print se.__class__, se
            print 'no peer certificate'
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
