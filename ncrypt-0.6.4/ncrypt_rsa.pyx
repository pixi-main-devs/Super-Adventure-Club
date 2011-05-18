cdef extern from "openssl/evp.h" :
    ctypedef struct EVP_CIPHER
    EVP_CIPHER *EVP_des_ede3_cbc()

cdef extern from "openssl/crypto.h" :
    void OPENSSL_free( void *p )

cdef extern from "openssl/bn.h" :
    ctypedef struct BIGNUM
    ctypedef struct BN_CTX
    BIGNUM *BN_new()
    void BN_free( BIGNUM *x )

cdef extern from "openssl/bio.h" :
    ctypedef struct BIO_METHOD
    ctypedef struct BIO
    BIO_METHOD *BIO_s_mem()
    BIO *BIO_new( BIO_METHOD *m )
    int BIO_free( BIO *b )
    int BIO_write( BIO *b, void *buf, int num )

cdef extern from "utils.h" :
    object BNToLong( BIGNUM *bn )
    int LongToBN( object x, BIGNUM *bn )
    object GetBIOData( BIO *b )

cdef extern from "openssl/rsa.h" :
    cdef enum :
        RSA_PKCS1_PADDING
        RSA_PKCS1_OAEP_PADDING

    RSA *RSA_new()
    void RSA_free( RSA *x )
    RSA *RSAPublicKey_dup( RSA *x )
    RSA *RSAPrivateKey_dup( RSA *x )
    int RSA_size( RSA *x )
    RSA *RSA_generate_key( int num, int e, void (*callback)(int,int,void*),
            void *cb_arg )
    int RSA_check_key( RSA *x )
    int RSA_blinding_on( RSA *x, BN_CTX *bnctx )
    void RSA_blinding_off( RSA *x )

    int RSA_public_encrypt( int srcLen, unsigned char *src, unsigned char *dest,
            RSA *x, int padding )
    int RSA_private_decrypt( int srcLen, unsigned char *src, unsigned char *dest,
            RSA *x, int padding )

    int RSA_sign( int type, unsigned char *m, unsigned int mlen,
            unsigned char *sigret, unsigned int *siglen, RSA *x )
    int RSA_verify( int type, unsigned char *m, unsigned int mlen,
            unsigned char *sigbuf, unsigned int siglen, RSA *x )

    int i2d_RSAPublicKey( RSA *r, unsigned char **out )
    RSA *d2i_RSAPublicKey( RSA **r, unsigned char **inp, int len )

    int i2d_RSAPrivateKey( RSA *r, unsigned char **out )
    RSA *d2i_RSAPrivateKey( RSA **r, unsigned char **inp, int len )

cdef extern from "openssl/pem.h" :
    int PEM_write_bio_RSAPublicKey( BIO *b, RSA *r )
    RSA *PEM_read_bio_RSAPublicKey( BIO *b, void *, void *, void * )
    int PEM_write_bio_RSAPrivateKey( BIO *b, RSA *r,
            EVP_CIPHER *, void *, int, void *, void * )
    RSA *PEM_read_bio_RSAPrivateKey( BIO *b, void *, void *, void * )

cdef extern from "stdlib.h" :
    void *malloc( int size )
    void free( void *ptr )

cdef extern from "string.h":
    void *memcpy(void *dest, void*src, int n)

cdef extern from "Python.h" :
    ctypedef struct PyObject
    void Py_DECREF( PyObject *obj )
    void Py_INCREF( PyObject *obj )
    int PyInt_Check( object obj )
    int PyLong_Check( object obj )
    int PyString_Check( object obj )
    object PyLong_FromString( char *p, char **pend, int base )
    object PyObject_Str( object obj )
    char *PyString_AsString( object obj )
    int PyString_AsStringAndSize( object obj, char **ptr, int *len )
    object PyString_FromStringAndSize( char *p, int len )
    PyObject *Raw_PyString_FromStringAndSize "PyString_FromStringAndSize" ( char *s, int len )
    char *Raw_PyString_AsString "PyString_AsString" ( PyObject *s )

import ncrypt_err

cdef struct PemCbData :
    int length
    char *data

cdef int _password_callback(char *buf, int size, int rwflag, void *u) :
    cdef PemCbData* d
    cdef int cp_size
    d = <PemCbData*>u
    if d.data == NULL :
        buf[0] = <char>0
        return 0
    else:
        if size > d.length :
            cp_size = d.length
        else:
            cp_size = size
        memcpy( buf, d.data, cp_size )
        buf[size-1] = <char>0
        return cp_size

class RSAError(ncrypt_err.BaseLibraryError) : pass

cdef void _rsa_callback( int type, int num, void *cb_arg ) :
    cb = <object>cb_arg
    cb( type, num )

PADDING_PKCS1 = 0
PADDING_PKCS1_OAEP = 1

cdef class RSAKey :
    def __new__( self ) :
        self.rsa = RSA_new()

    def __dealloc__( self ) :
        RSA_free( self.rsa )

    def __init__( self ) :
        pass

    cdef void loadCPublicKey( self, RSA *r ) :
        cdef RSA *newrsa
        newrsa = RSAPublicKey_dup( r )
        RSA_free( self.rsa )
        self.rsa = newrsa

    cdef void loadCPrivateKey( self, RSA *r ) :
        cdef RSA *newrsa
        newrsa = RSAPrivateKey_dup( r )
        RSA_free( self.rsa )
        self.rsa = newrsa

    def generate( self, bits=1024, **kw ) :
        cdef RSA *newKey
        cdef int e

        e = kw.get( 'e', 5 )
        callback = kw.get( 'callback', None )
        if callback is None :
            newKey = RSA_generate_key( bits, e, NULL, NULL )
        else :
            newKey = RSA_generate_key( bits, e, _rsa_callback, <void *>callback )
        if newKey == NULL :
            raise RSAError, 'key generation failed'
        RSA_free( self.rsa )
        self.rsa = newKey

    def size( self ) :
        if not self.rsa.n :
            raise RSAError, 'key not initialized'
        return RSA_size( self.rsa )

    def check( self ) :
        cdef RSA *r
        r = self.rsa
        if (not r.e) or (not r.n) or (not r.d) :
            raise RSAError, 'private key not initialized'
        if (not r.p) or (not r.q) :
            raise RSAError, 'primes not initialized'
        return RSA_check_key( r )

    def enableBlinding( self, enable=True ) :
        if not self.rsa.d :
            raise RSAError, 'private key not initialized'
        cdef int result
        if enable :
            result = RSA_blinding_on( self.rsa, NULL )
            if not result :
                raise RSAError, 'unable to enable blinding'
        else :
            RSA_blinding_off( self.rsa )

    def getN( self ) :
        if not self.rsa.n :
            raise RSAError, "'n' not initialized"
        return BNToLong( self.rsa.n )

    def getE( self ) :
        if not self.rsa.e :
            raise RSAError, "'e' not initialized"
        return BNToLong( self.rsa.e )

    def getD( self ) :
        if not self.rsa.d :
            raise RSAError, "'d' not initialized"
        return BNToLong( self.rsa.d )

    def getP( self ) :
        if not self.rsa.p :
            raise RSAError, "'p' not initialized"
        return BNToLong( self.rsa.p )

    def getQ( self ) :
        if not self.rsa.q :
            raise RSAError, "'q' not initialized"
        return BNToLong( self.rsa.q )

    def hasPublicKey( self ) :
        if not self.rsa.n : return False
        if not self.rsa.e : return False
        return True

    def hasPrivateKey( self ) :
        if not self.rsa.d : return False
        return True

    def getPublicKey( self ) :
        cdef RSA *r
        r = self.rsa
        if (not r.n) or (not r.e) :
            raise RSAError, 'key not initialized'
        return (BNToLong(r.n),BNToLong(r.e))

    def getPrivateKey( self ) :
        cdef RSA *r
        cdef BIGNUM *x
        r = self.rsa
        if (not r.n) or (not r.e) or (not r.d) :
            raise RSAError, 'private key not initialized'
        if (not r.p) or (not r.q) or (not r.dmp1) or (not r.dmq1) or (not r.iqmp) :
            raise RSAError, 'private key not initialized'
        return (BNToLong(r.n),BNToLong(r.e),BNToLong(r.d),
                BNToLong(r.p),BNToLong(r.q),BNToLong(r.dmp1),BNToLong(r.dmq1),
                BNToLong(r.iqmp))

    def loadPublicKey( self, publicKey ) :
        cdef BIGNUM *bn_n, *bn_e
        cdef int result1, result2
        n,e = publicKey
        bn_n, bn_e = BN_new(), BN_new()
        result1 = LongToBN( n, bn_n )
        result2 = LongToBN( e, bn_e )
        if (result1 < 0) or (result2 < 0) :
            BN_free( bn_n )
            BN_free( bn_e )
            raise RSAError, 'invalid public key'
        RSA_free( self.rsa )
        self.rsa = RSA_new()
        self.rsa.n, self.rsa.e = bn_n, bn_e

    def loadPrivateKey( self, privateKey ) :
        cdef BIGNUM *bn[8]
        cdef int i, result
        if len(privateKey) != 8 :
            raise TypeError, 'private key must have 8 elements'
        for i from 0 <= i < 8 : bn[i] = BN_new()
        for i from 0 <= i < 8 :
            result = LongToBN( privateKey[i], bn[i] )
            if result < 0 :
                for i from 0 <= i < 8 :
                    BN_free( bn[i] )
                raise RSAError, 'invalid private key'
        RSA_free( self.rsa )
        self.rsa = RSA_new()
        cdef RSA *r
        r = self.rsa
        r.n, r.e, r.d, r.p, r.q = bn[0], bn[1], bn[2], bn[3], bn[4]
        r.dmp1, r.dmq1, r.iqmp = bn[5], bn[6], bn[7]

    def paddingSize( self, paddingMode ) :
        if paddingMode == PADDING_PKCS1 : return 12
        if paddingMode == PADDING_PKCS1_OAEP : return 42
        raise RSAError, 'unknown padding mode'

    def maxInputSize( self, paddingMode=PADDING_PKCS1_OAEP ) :
        return self.size() - self.paddingSize(paddingMode)

    def encrypt( self, data, paddingMode=PADDING_PKCS1_OAEP ) :
        cdef int paddingCode
        if paddingMode == PADDING_PKCS1 :
            paddingCode = RSA_PKCS1_PADDING
        elif paddingMode == PADDING_PKCS1_OAEP :
            paddingCode = RSA_PKCS1_OAEP_PADDING
        else :
            raise RSAError, 'unknown padding mode'

        if (not self.rsa.n) or (not self.rsa.e) :
            raise RSAError, 'public key not initialized'

        size = self.size()
        maxSize = self.maxInputSize(paddingMode)
        if len(data) > maxSize :
            raise RSAError, 'encryption input is too long, maxsize=%d' % maxSize

        cdef int result

        cdef unsigned char *plainText
        cdef int plainTextLen
        result = PyString_AsStringAndSize( data, <char **>&plainText, &plainTextLen )
        if result < 0 :
            raise TypeError, "'data' must be a string"

        cdef unsigned char *cipherText
        cipherText = <unsigned char *>malloc( size )

        cdef int cipherTextLen
        cipherTextLen = RSA_public_encrypt( plainTextLen, plainText,
                cipherText, self.rsa, paddingCode )
        if cipherTextLen < 0 :
            free( cipherText )
            raise RSAError, 'RSA encryption failed'
        assert cipherTextLen == size

        try :
            return PyString_FromStringAndSize( <char *>cipherText, cipherTextLen )
        finally :
            free( cipherText )

    def decrypt( self, data, paddingMode=PADDING_PKCS1_OAEP ) :
        cdef int paddingCode
        paddingCode = -1
        if paddingMode == PADDING_PKCS1 :
            paddingCode = RSA_PKCS1_PADDING
        elif paddingMode == PADDING_PKCS1_OAEP :
            paddingCode = RSA_PKCS1_OAEP_PADDING
        else :
            raise RSAError, 'unknown padding mode'

        if (not self.rsa.n) or (not self.rsa.e) or (not self.rsa.d) :
            raise RSAError, 'private key not initialized'

        size = self.size()

        cdef int result

        cdef unsigned char *cipherText
        cdef int cipherTextLen
        result = PyString_AsStringAndSize( data, <char **>&cipherText, &cipherTextLen )
        if result < 0 :
            raise TypeError, "'data' must be a string"

        cdef unsigned char *plainText
        cdef int plainTextLen
        plainText = <unsigned char *>malloc( self.size() )

        plainTextLen = RSA_private_decrypt( cipherTextLen, cipherText,
                plainText, self.rsa, paddingCode )
        if plainTextLen < 0 :
            free( plainText )
            raise RSAError, 'RSA decryption failed'

        try :
            return PyString_FromStringAndSize( <char *>plainText, plainTextLen )
        finally :
            free( plainText )

    def sign( self, digest, digestType ) :
        if (not self.rsa.n) or (not self.rsa.e) or (not self.rsa.d) :
            raise RSAError, 'private key not initialized'

        cdef int nid
        nid = digestType.nid()

        cdef int result

        cdef unsigned char *digestBuf
        cdef unsigned int digestLen
        result = PyString_AsStringAndSize( digest, <char **>&digestBuf,
                <int *>&digestLen )
        if result < 0 :
            raise TypeError, "'digest' must be a string"

        cdef int size
        size = self.size()

        cdef unsigned char *sigBuf
        cdef unsigned int sigLen
        sigLen = size
        sigBuf = <unsigned char *>malloc( sigLen )

        result = RSA_sign( nid, digestBuf, digestLen, sigBuf, &sigLen, self.rsa )
        if not result :
            free( sigBuf )
            raise RSAError, 'RSA sign failed'

        try :
            return PyString_FromStringAndSize( <char *>sigBuf, <int>sigLen )
        finally :
            free( sigBuf )

    def verify( self, signature, digest, digestType ) :
        if (not self.rsa.n) or (not self.rsa.e) :
            raise RSAError, 'public key not initialized'

        cdef int nid
        nid = digestType.nid()

        cdef int result

        cdef unsigned char *digestBuf
        cdef unsigned int digestLen
        result = PyString_AsStringAndSize( digest, <char **>&digestBuf,
                <int *>&digestLen )
        if result < 0 :
            raise TypeError, "'digest' must be a string"

        cdef unsigned char *sigBuf
        cdef unsigned int sigLen
        result = PyString_AsStringAndSize( signature, <char **>&sigBuf,
                <int *>&sigLen )
        if result < 0 :
            raise TypeError, "'signature' must be a string"

        result = RSA_verify( nid, digestBuf, digestLen, sigBuf, sigLen, self.rsa )
        if not result :
            raise RSAError, 'RSA verify failed'

    def fromDER_PrivateKey( self, data ) :
        cdef RSA *newrsa
        cdef char *p
        cdef int dataLen, result
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        newrsa = d2i_RSAPrivateKey( NULL, <unsigned char **>&p, dataLen )
        if not newrsa :
            raise RSAError, 'unable to load object from data'
        RSA_free( self.rsa )
        self.rsa = newrsa

    def toDER_PrivateKey( self ) :
        cdef int len, len1
        cdef PyObject *derStr
        if not self.hasPrivateKey() :
            raise RSAError, 'private key not initialized'
        len = i2d_RSAPrivateKey( self.rsa, NULL )
        if len < 0 :
            raise RSAError, 'error in private key data'
        derStr = Raw_PyString_FromStringAndSize( NULL, len )
        if derStr == NULL :
            raise MemoryError, 'unable to allocate string'
        cdef char *p
        p = Raw_PyString_AsString( derStr )
        try :
            len1 = i2d_RSAPrivateKey( self.rsa, <unsigned char **>&p )
            assert len == len1
            return <object>derStr
        finally :
            Py_DECREF( derStr )

    def fromDER_PublicKey( self, data ) :
        cdef RSA *newrsa
        cdef char *p
        cdef int dataLen, result
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        newrsa = d2i_RSAPublicKey( NULL, <unsigned char **>&p, dataLen )
        if not newrsa :
            raise RSAError, 'unable to load object from data'
        RSA_free( self.rsa )
        self.rsa = newrsa

    def toDER_PublicKey( self ) :
        cdef int len, len1
        cdef PyObject *derStr
        if not self.hasPublicKey() :
            raise RSAError, 'public key not initialized'
        len = i2d_RSAPublicKey( self.rsa, NULL )
        if len < 0 :
            raise RSAError, 'error in public key data'
        derStr = Raw_PyString_FromStringAndSize( NULL, len )
        if derStr == NULL :
            raise MemoryError, 'unable to allocate string'
        cdef char *p
        p = Raw_PyString_AsString( derStr )
        try :
            len1 = i2d_RSAPublicKey( self.rsa, <unsigned char **>&p )
            assert len == len1
            return <object>derStr
        finally :
            Py_DECREF( derStr )

    def fromPEM_PrivateKey( self, data, password=None ) :
        cdef char *p
        cdef int dataLen, result
        cdef PemCbData passwd_cb_data
        cdef BIO *b
        cdef RSA *newrsa
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise RSAError, 'unable to allocate BIO structure'
        try :
            result = BIO_write( b, p, dataLen )
            if result < 0 :
                raise RSAError, 'unable to write data to BIO'
            if password is None :
                passwd_cb_data.data = NULL
                passwd_cb_data.length = 0
            else :
                result = PyString_AsStringAndSize( password, &p, &dataLen )
                if result < 0 :
                    raise TypeError, 'password is not a string'
                else:
                    passwd_cb_data.data = p
                    passwd_cb_data.length = dataLen
            newrsa = PEM_read_bio_RSAPrivateKey( b, NULL, &_password_callback, <void*>&passwd_cb_data )
            if not newrsa :
                raise RSAError, 'unable to load object from data'
            RSA_free( self.rsa )
            self.rsa = newrsa
        finally :
            BIO_free( b )

    def toPEM_PrivateKey( self, password=None ) :
        if not self.hasPrivateKey() :
            raise RSAError, 'private key not initialized'
        cdef char *p,*q
        cdef int dataLen, result
        cdef BIO *b
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise RSAError, 'unable to allocate a BIO structure'
        try :
            if password is None :
                result = PEM_write_bio_RSAPrivateKey( b, self.rsa,
                        NULL, NULL, 0, NULL, NULL )
            else:
                result = PyString_AsStringAndSize( password, &p, &dataLen )
                if result < 0 :
                    raise TypeError, 'password is not a string'
                q = <char*>( malloc( dataLen ) ) # Since PEM_write_bio_RSAPrivateKey does'nt guarantee that p will be unmodified
                if q == NULL :
                    raise MemoryError, 'error allocating memory for password'
                memcpy( q, p, dataLen )
                try :
                    result = PEM_write_bio_RSAPrivateKey( b, self.rsa,
                        EVP_des_ede3_cbc(), p, dataLen, NULL, NULL )
                finally :
                    free( q )
            if not result :
                raise RSAError, 'error in public key data'
            ret = GetBIOData( b )
            if ret is None :
                raise RSAError, 'error in creating PEM data'
            return ret
        finally :
            BIO_free( b )

    def fromPEM_PublicKey( self, data ) :
        cdef char *p
        cdef int dataLen, result
        cdef BIO *b
        cdef RSA *newrsa
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise RSAError, 'unable to allocate BIO structure'
        try :
            result = BIO_write( b, p, dataLen )
            if result < 0 :
                raise RSAError, 'unable to write data to BIO'
            newrsa = PEM_read_bio_RSAPublicKey( b, NULL, NULL, NULL )
            if not newrsa :
                raise RSAError, 'unable to load object from data'
            RSA_free( self.rsa )
            self.rsa = newrsa
        finally :
            BIO_free( b )

    def toPEM_PublicKey( self ) :
        if not self.hasPublicKey() :
            raise RSAError, 'public key not initialized'
        cdef int result
        cdef BIO *b
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise RSAError, 'unable to allocate a BIO structure'
        try :
            result = PEM_write_bio_RSAPublicKey( b, self.rsa )
            if not result :
                raise RSAError, 'error in public key data'
            ret = GetBIOData( b )
            if ret is None :
                raise RSAError, 'error in creating PEM data'
            return ret
        finally :
            BIO_free( b )
