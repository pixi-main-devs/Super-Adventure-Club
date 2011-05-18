cdef extern from "openssl/bn.h" :
    ctypedef struct BIGNUM
    BIGNUM *BN_new()
    void BN_free( BIGNUM *x )

cdef extern from "openssl/dh.h" :
    DH_s *DH_new()
    void DH_free( DH_s *dh )
    int DH_size( DH_s *dh )
    DH_s *DH_generate_parameters( int prime_len, int generator,
            void (*callback)(int,int,void *), void *cb_arg )
    int DH_check( DH_s *dh, int *codes )
    int DH_generate_key( DH_s *dh )
    int DH_compute_key( unsigned char *key, BIGNUM *pub_key, DH_s *dh )

    int i2d_DHparams( DH_s *dh, unsigned char **out )
    DH_s *d2i_DHparams( DH_s **dh, unsigned char **inp, int len )

cdef extern from "openssl/bio.h" :
    ctypedef struct BIO_METHOD
    ctypedef struct BIO
    BIO_METHOD *BIO_s_mem()
    BIO *BIO_new( BIO_METHOD *m )
    int BIO_free( BIO *b )
    int BIO_write( BIO *b, void *buf, int num )

cdef extern from "openssl/pem.h" :
    int PEM_write_bio_DHparams( BIO *b, DH_s *s )
    DH_s *PEM_read_bio_DHparams( BIO *b, void *, void *, void * )

cdef extern from "utils.h" :
    object BNToLong( BIGNUM *bn )
    int LongToBN( object x, BIGNUM *bn )
    object GetBIOData( BIO *b )

cdef extern from "stdlib.h" :
    void *malloc( int size )
    void free( void *ptr )

cdef extern from "Python.h" :
    ctypedef struct PyObject
    void Py_DECREF( PyObject *obj )
    int PyString_AsStringAndSize( object obj, char **ptr, int *len )
    object PyString_FromStringAndSize( char *p, int len )
    PyObject *Raw_PyString_FromStringAndSize "PyString_FromStringAndSize"( char *s, int len )
    char *Raw_PyString_AsString "PyString_AsString" ( PyObject *o )

import ncrypt_err

class DHError( ncrypt_err.BaseLibraryError ) : pass

cdef class DH :
    def __new__( self ) :
        self.dh = DH_new()

    def __dealloc__( self ) :
        DH_free( self.dh )

    def __init__( self ) :
        pass

    def size( self ) :
        if (not self.dh.p) or (not self.dh.g) :
            raise DHError, 'dh params not initialized'
        return DH_size( self.dh )

    def generateParameters( self, primeLen, generator ) :
        cdef DH_s *newdh
        newdh = DH_generate_parameters( primeLen, generator,
                NULL, NULL )
        if not newdh :
            raise DHError, 'error generating dh parameters'
        DH_free( self.dh )
        self.dh = newdh

    def check( self ) :
        if (not self.dh.p) or (not self.dh.g) :
            raise DHError, 'dh params not initialized'
        cdef int result, codes
        result = DH_check( self.dh, &codes )
        if not result :
            raise DHError, 'error in check dh params'
        if codes :
            msg = 'dh params are not ok (%d)' % codes
            raise DHError, msg

    def generateKey( self ) :
        if (not self.dh.p) or (not self.dh.g) :
            raise DHError, 'dh params are not initialized'
        cdef int result
        result = DH_generate_key( self.dh )
        if not result :
            raise DHError, 'error in generating key'

    def computeKey( self, peerPubKey ) :
        if (not self.dh.p) or (not self.dh.g) :
            raise DHError, 'dh params are not initialized'
        if (not self.dh.priv_key) or (not self.dh.pub_key) :
            raise DHError, 'dh private key not initialized'
        cdef BIGNUM *bn_peerPubKey
        cdef int result
        bn_peerPubKey = BN_new()
        result = LongToBN( peerPubKey, bn_peerPubKey )
        if result < 0 :
            BN_free( bn_peerPubKey )
            raise DHError, 'invalid peerPubKey value'
        cdef unsigned char *keyBuf
        keyBuf = <unsigned char *>malloc( DH_size(self.dh) )
        result = DH_compute_key( keyBuf, bn_peerPubKey, self.dh )
        BN_free( bn_peerPubKey )
        if result < 0 :
            free( keyBuf )
            raise DHError, 'error in computing shared key'
        sharedKey = PyString_FromStringAndSize( <char *>keyBuf, result )
        free( keyBuf )
        return sharedKey

    def getP( self ) :
        if not self.dh.p :
            return None
        return BNToLong( self.dh.p )

    def setP( self, p ) :
        cdef BIGNUM *bn_p
        cdef int result
        bn_p = BN_new()
        result = LongToBN( p, bn_p )
        if result < 0 :
            BN_free( bn_p )
            raise DHError, 'invalid p value'
        if self.dh.p :
            BN_free( self.dh.p )
        self.dh.p = bn_p

    def getG( self ) :
        if not self.dh.g :
            return None
        return BNToLong( self.dh.g )

    def setG( self, g ) :
        cdef BIGNUM *bn_g
        cdef int result
        bn_g = BN_new()
        result = LongToBN( g, bn_g )
        if result < 0 :
            BN_free( bn_g )
            raise DHError, 'invalid g value'
        if self.dh.g :
            BN_free( self.dh.g )
        self.dh.g = bn_g

    def getPublicKey( self ) :
        if not self.dh.pub_key :
            return None
        return BNToLong( self.dh.pub_key )

    def setPublicKey( self, pubKey ) :
        cdef BIGNUM *bn_pubKey
        cdef int result
        bn_pubKey = BN_new()
        result = LongToBN( pubKey, bn_pubKey )
        if result < 0 :
            BN_free( bn_pubKey )
            raise DHError, 'invalid pubKey value'
        if self.dh.pub_key :
            BN_free( self.dh.pub_key )
        self.dh.pub_key = bn_pubKey

    def getPrivateKey( self ) :
        if not self.dh.priv_key :
            return None
        return BNToLong( self.dh.priv_key )

    def setPrivateKey( self, privKey ) :
        cdef BIGNUM *bn_privKey
        cdef int result
        bn_privKey = BN_new()
        result = LongToBN( privKey, bn_privKey )
        if result < 0 :
            BN_free( bn_privKey )
            raise DHError, 'invalid privKey value'
        if self.dh.priv_key :
            BN_free( self.dh.priv_key )
        self.dh.priv_key = bn_privKey

    def fromDER_Parameters( self, data ) :
        cdef char *p
        cdef int result, dataLen
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        cdef DH_s *newdh
        newdh = d2i_DHparams( NULL, <unsigned char **>&p, dataLen )
        if not newdh :
            raise DHError, 'unable to load object from data'
        DH_free( self.dh )
        self.dh = newdh

    def toDER_Parameters( self ) :
        if (not self.dh.p) or (not self.dh.g) :
            raise DHError, 'dh params not initialized'
        cdef int len
        len = i2d_DHparams( self.dh, NULL )
        if len < 0 :
            raise DHError, 'error in dh params data'
        cdef PyObject *derStr
        derStr = Raw_PyString_FromStringAndSize( NULL, len )
        if derStr == NULL :
            raise MemoryError, 'unable to allocate string'
        cdef char *p
        p = Raw_PyString_AsString( derStr )
        try :
            len1 = i2d_DHparams( self.dh, <unsigned char **>&p )
            assert len == len1
            return <object>derStr
        finally :
            Py_DECREF( derStr )

    def fromPEM_Parameters( self, data ) :
        cdef char *p
        cdef int dataLen, result
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        cdef BIO *b
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise DHError, 'unable to allocate BIO structure'
        cdef DH_s *newdh
        try :
            result = BIO_write( b, p, dataLen )
            if result < 0 :
                raise DHError, 'unable to write data to BIO'
            newdh = PEM_read_bio_DHparams( b, NULL, NULL, NULL )
            if not newdh :
                raise DHError, 'unable to load object from data'
            DH_free( self.dh )
            self.dh = newdh
        finally :
            BIO_free( b )

    def toPEM_Parameters( self ) :
        if (not self.dh.p) or (not self.dh.g) :
            raise DHError, 'dh params not initialized'
        cdef BIO *b
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise DHError, 'unable to allocate a BIO structure'
        cdef int result
        try :
            result = PEM_write_bio_DHparams( b, self.dh )
            if not result :
                raise DHError, 'error in dh params data'
            ret = GetBIOData( b )
            if ret is None :
                raise DHError, 'error in creating PEM data'
            return ret
        finally :
            BIO_free( b )
