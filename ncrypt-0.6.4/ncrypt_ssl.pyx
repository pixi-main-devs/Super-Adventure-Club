from ncrypt_x509 cimport X509
cimport ncrypt_x509

from ncrypt_dh cimport DH_s
cimport ncrypt_dh

from ncrypt_rsa cimport RSA
cimport ncrypt_rsa

import ncrypt_err
import ncrypt_x509

cdef extern from "openssl/rsa.h" :
    void RSA_free( RSA *x )
    RSA *RSAPrivateKey_dup( RSA *x )

cdef extern from "openssl/x509.h" :
    X509 *X509_dup( X509 *x )
    void X509_free( X509 *x )

    ctypedef struct X509_STORE_CTX
    int X509_STORE_CTX_get_error( X509_STORE_CTX *ctx )
    cdef enum :
        X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT

cdef extern from "openssl/ssl.h" :
    ctypedef struct SSL_METHOD
    SSL_METHOD *SSLv2_method()
    SSL_METHOD *SSLv2_client_method()
    SSL_METHOD *SSLv2_server_method()
    SSL_METHOD *SSLv3_method()
    SSL_METHOD *SSLv3_client_method()
    SSL_METHOD *SSLv3_server_method()
    SSL_METHOD *TLSv1_method()
    SSL_METHOD *TLSv1_client_method()
    SSL_METHOD *TLSv1_server_method()
    SSL_METHOD *SSLv23_method()
    SSL_METHOD *SSLv23_client_method()
    SSL_METHOD *SSLv23_server_method()

    ctypedef struct SSL_CTX
    SSL_CTX *SSL_CTX_new( SSL_METHOD *meth )
    void SSL_CTX_free( SSL_CTX *ctx )
    long SSL_CTX_set_session_cache_mode( SSL_CTX *ctx, long mode )
    long SSL_CTX_set_mode( SSL_CTX *ctx, long mode )
    int SSL_CTX_use_certificate( SSL_CTX *ctx, X509 *x )
    int SSL_CTX_use_RSAPrivateKey( SSL_CTX *ctx, RSA *r )
    void SSL_CTX_set_verify( SSL_CTX *ctx, int mode, int (*verify_callback)(int,X509_STORE_CTX*) )
    long SSL_CTX_set_tmp_dh( SSL_CTX *ctx, DH_s *dh )
    long SSL_CTX_set_options( SSL_CTX *ctx, long options )
    cdef enum :
        SSL_SESS_CACHE_OFF
        SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER

        SSL_VERIFY_NONE
        SSL_VERIFY_PEER
        SSL_VERIFY_FAIL_IF_NO_PEER_CERT
        SSL_VERIFY_CLIENT_ONCE

        SSL_OP_SINGLE_DH_USE

    ctypedef struct SSL
    SSL *SSL_new( SSL_CTX *ctx )
    void SSL_free( SSL *ssl )
    int SSL_set_fd( SSL *ssl, int fd )
    int SSL_get_error( SSL *ssl, int ret )
    int SSL_connect( SSL *ssl )
    int SSL_accept( SSL *ssl )
    int SSL_get_verify_result( SSL *ssl )
    X509 *SSL_get_peer_certificate( SSL *ssl )
    int SSL_pending( SSL *ssl )
    int SSL_read( SSL *ssl, void *buf, int num )
    int SSL_write( SSL *ssl, void *buf, int num )
    int SSL_shutdown( SSL *ssl )
    cdef enum :
        SSL_ERROR_NONE
        SSL_ERROR_ZERO_RETURN
        SSL_ERROR_WANT_READ
        SSL_ERROR_WANT_WRITE
        SSL_ERROR_WANT_X509_LOOKUP
        SSL_ERROR_SYSCALL
        SSL_ERROR_SSL

cdef extern from "openssl/err.h" :
    void ERR_clear_error()

cdef extern from "Python.h" :
    ctypedef struct PyObject
    void Py_DECREF( PyObject *obj )
    void Py_XDECREF( PyObject *obj )
    void Py_INCREF( PyObject *obj )
    int PyString_AsStringAndSize( PyObject *obj, char **buffer, int *length )
    PyObject *PyString_FromStringAndSize( char *buf, int buf_size )
    int _PyString_Resize( PyObject **s, int newsize )
    char *PyString_AsString( PyObject *s )

SSL_METHOD_SSLv2 = 0
SSL_METHOD_SSLv3 = 1
SSL_METHOD_TLSv1 = 2
SSL_METHOD_SSLv23 = 3
SSL_METHOD_MAX = 4

SSL_METHOD_TYPE_CLIENT = 0
SSL_METHOD_TYPE_SERVER = 1
SSL_METHOD_TYPE_GENERIC = 2
SSL_METHOD_TYPE_MAX = 3

class SSLError( ncrypt_err.BaseError ) : pass

class SSLCertificateError( SSLError ) : pass

class SSLWantError( SSLError ) : pass
class SSLWantReadError( SSLWantError ) : pass
class SSLWantWriteError( SSLWantError ) : pass
class SSLWantX509LookupError( SSLWantError ) : pass

class SSLZeroReturnError( SSLError ) : pass

class SSLLibraryError( SSLError, ncrypt_err.LibraryErrorInfo ) :
    def __init__( self, *args ) :
        ncrypt_err.LibraryErrorInfo.initErrorInfo( self )
        args = self.updateArgs( args )
        SSLError.__init__( self, *args )

class SSLSysCallError( SSLLibraryError ) : pass
class SSLProtocolError( SSLLibraryError ) : pass

SSL_VERIFY_MODE_NONE = 0
SSL_VERIFY_MODE_SELF_SIGNED = 1
SSL_VERIFY_MODE_MAX = 2

cdef SSL_METHOD *getSSLMethod( int method, int methodType ) :
    m, t = method, methodType
    if m == SSL_METHOD_SSLv2 :
        if t == SSL_METHOD_TYPE_CLIENT :
            return SSLv2_client_method()
        elif t == SSL_METHOD_TYPE_SERVER :
            return SSLv2_server_method()
        elif t == SSL_METHOD_TYPE_GENERIC :
            return SSLv2_method()
    elif m == SSL_METHOD_SSLv3 :
        if t == SSL_METHOD_TYPE_CLIENT :
            return SSLv3_client_method()
        elif t == SSL_METHOD_TYPE_SERVER :
            return SSLv3_server_method()
        elif t == SSL_METHOD_TYPE_GENERIC :
            return SSLv3_method()
    elif m == SSL_METHOD_TLSv1 :
        if t == SSL_METHOD_TYPE_CLIENT :
            return TLSv1_client_method()
        elif t == SSL_METHOD_TYPE_SERVER :
            return TLSv1_server_method()
        elif t == SSL_METHOD_TYPE_GENERIC :
            return TLSv1_method()
    elif m == SSL_METHOD_SSLv23 :
        if t == SSL_METHOD_TYPE_CLIENT :
            return SSLv23_client_method()
        elif t == SSL_METHOD_TYPE_SERVER :
            return SSLv23_server_method()
        elif t == SSL_METHOD_TYPE_GENERIC :
            return SSLv23_method()
    return NULL

cdef int SelfSignedVerifyCallback( int preverify_ok, X509_STORE_CTX *ctx ) :
    if preverify_ok : return 1
    cdef int verifyErr
    verifyErr = X509_STORE_CTX_get_error( ctx )
    if verifyErr == X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT :
        return 1
    return 0

cdef class SSLContext :
    cdef SSL_CTX *c

    def __new__( self, sslMethod, sslMethodType=-1 ) :
        self.c = NULL

    def __dealloc__( self ) :
        if self.c :
            SSL_CTX_free( self.c )

    def __init__( self, int sslMethod, int sslMethodType=-1 ) :
        if (sslMethod < 0) or (sslMethod >= SSL_METHOD_MAX) :
            raise ValueError, 'invalid ssl method'
        if sslMethodType == -1 :
            sslMethodType = SSL_METHOD_TYPE_GENERIC
        if (sslMethodType < 0) or (sslMethodType >= SSL_METHOD_TYPE_MAX) :
            raise ValueError, 'invalid ssl method type'
        if self.c :
            SSL_CTX_free( self.c )
            self.c = NULL
        self.c = SSL_CTX_new( getSSLMethod(sslMethod,sslMethodType) )
        if not self.c :
            raise SSLLibraryError, 'unable to initialize ssl context'
        SSL_CTX_set_session_cache_mode( self.c, <long>SSL_SESS_CACHE_OFF )
        SSL_CTX_set_mode( self.c, <long>SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER )

    def setCertificate( self, ncrypt_x509.X509Certificate x not None ) :
        cdef X509 *x1
        x1 = X509_dup( x.x )
        if not x1 :
            raise SSLLibraryError, 'unable to allocate X509 certificate'
        cdef int result
        try :
            result = SSL_CTX_use_certificate( self.c, x1 )
            if not result :
                raise SSLLibraryError, 'unable to set certificate'
        finally :
            X509_free( x1 )

    def setPrivateKey( self, ncrypt_rsa.RSAKey rk not None ) :
        if not rk.hasPrivateKey() :
            raise SSLLibraryError, 'RSA private key not initialized'
        cdef RSA *rk1
        rk1 = RSAPrivateKey_dup( rk.rsa )
        if not rk1 :
            raise SSLLibraryError, 'unable to allocate RSA private key'
        cdef int result
        try :
            result = SSL_CTX_use_RSAPrivateKey( self.c, rk1 )
            if not result :
                raise SSLLibraryError, 'unable to set RSA private key'
        finally :
            RSA_free( rk1 )

    def setVerifyMode( self, int mode ) :
        if (mode < 0) or (mode >= SSL_VERIFY_MODE_MAX) :
            raise ValueError, 'invalid verification mode'
        if mode == SSL_VERIFY_MODE_NONE :
            SSL_CTX_set_verify( self.c, SSL_VERIFY_NONE, NULL )
        elif mode == SSL_VERIFY_MODE_SELF_SIGNED :
            SSL_CTX_set_verify( self.c,
                    SSL_VERIFY_PEER|SSL_VERIFY_FAIL_IF_NO_PEER_CERT|SSL_VERIFY_CLIENT_ONCE,
                    SelfSignedVerifyCallback )

    def enableDH( self, ncrypt_dh.DH dh not None ) :
        cdef long result
        result = SSL_CTX_set_tmp_dh( self.c, dh.dh )
        if not result :
            raise SSLLibraryError, 'unable to enable dh'
        SSL_CTX_set_options( self.c, SSL_OP_SINGLE_DH_USE )

cdef class SSLConnection :
    cdef SSL *s
    cdef object sslContext
    cdef readonly object sock

    def __new__( self, sslContext, sock ) :
        self.s = NULL

    def __dealloc__( self ) :
        if self.s :
            SSL_free( self.s )

    def __init__( self, SSLContext sslContext not None, sock ) :
        if self.s :
            SSL_free( self.s )
            self.s = NULL
        self.s = SSL_new( sslContext.c )
        if not self.s :
            raise SSLLibraryError, 'unable to initialize ssl state'
        self.sslContext = sslContext
        self.sock = sock
        cdef int result
        result = SSL_set_fd( self.s, sock.fileno() )
        if result == 0 :
            raise SSLLibraryError, 'unable to set socket fd'

    cdef object getSSLError( self, int result ) :
        cdef int err
        err = SSL_get_error( self.s, result )
        if err == SSL_ERROR_WANT_READ :
            return SSLWantReadError( 'SSL needs more readable data' )
        if err == SSL_ERROR_WANT_WRITE :
            return SSLWantWriteError( 'SSL needs to write more data' )
        if err == SSL_ERROR_WANT_X509_LOOKUP :
            return SSLWantX509LookupError( 'SSL x509 callback is pending' )
        if err == SSL_ERROR_ZERO_RETURN :
            return SSLZeroReturnError( 'SSL connection has shutdown' )
        if err == SSL_ERROR_SYSCALL :
            return SSLSysCallError( 'SSL internal syscall error' )
        if err == SSL_ERROR_SSL :
            return SSLProtocolError( 'SSL protocol error' )
        assert err != SSL_ERROR_NONE
        return SSLLibraryError( 'unknown SSL error' )

    def connect( self ) :
        ERR_clear_error()
        cdef int result, err
        result = SSL_connect( self.s )
        if result <= 0 :
            raise self.getSSLError( result )

    def accept( self ) :
        ERR_clear_error()
        cdef int result, err
        result = SSL_accept( self.s )
        if result <= 0 :
            raise self.getSSLError( result )

    def getVerifyResult( self ) :
        return SSL_get_verify_result( self.s )

    def getPeerCertificate( self ) :
        cdef X509 *x
        x = SSL_get_peer_certificate( self.s )
        if not x :
            raise SSLCertificateError, 'no peer certificate available'
        cdef ncrypt_x509.X509Certificate cert
        cdef int result
        try :
            cert = ncrypt_x509.X509Certificate()
            result = cert.fromX509( x )
            if not result :
                raise SSLLibraryError, 'unable to allocate copy certificate'
            return cert
        finally :
            X509_free( x )

    def pending( self ) :
        return SSL_pending( self.s )

    def recv( self, int bufsize ) :
        ERR_clear_error()
        cdef PyObject *buf
        cdef char *ptr
        buf = PyString_FromStringAndSize( NULL, bufsize )
        if not buf :
            raise MemoryError, 'unable to allocate string'
        cdef int result
        try :
            ptr = PyString_AsString( buf )
            assert ptr != NULL
            result = SSL_read( self.s, ptr, bufsize )
            if result <= 0 :
                e = self.getSSLError( result )
                if isinstance(e,SSLZeroReturnError ) :
                    return ''
                raise e
            if result != bufsize :
                result = _PyString_Resize( &buf, result )
                assert result == 0
            return <object>buf
        finally :
            Py_XDECREF( buf )

    def send( self, data ) :
        ERR_clear_error()
        cdef char *ptr
        cdef int dataLen, result
        result = PyString_AsStringAndSize( <PyObject *>data, &ptr, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        if dataLen == 0 :
            return 0
        result = SSL_write( self.s, ptr, dataLen )
        if result <= 0 :
            raise self.getSSLError( result )
        return result

    def shutdown( self ) :
        cdef int result
        result = SSL_shutdown( self.s )
        if result < 0 :
            raise self.getSSLError( result )
        return result
