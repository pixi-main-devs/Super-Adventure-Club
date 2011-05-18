cdef extern from "openssl/evp.h" :
    ctypedef struct EVP_CIPHER_CTX
    ctypedef struct EVP_CIPHER
    EVP_CIPHER *EVP_get_cipherbyname( char *name )
    void EVP_add_cipher( EVP_CIPHER *evpCipher )
    void EVP_add_cipher_alias( char *realName, char *aliasName )
    char *EVP_CIPHER_name( EVP_CIPHER *evpCipher )
    int EVP_CIPHER_block_size( EVP_CIPHER *evpCipher )
    int EVP_CIPHER_key_length( EVP_CIPHER *evpCipher )
    int EVP_CIPHER_iv_length( EVP_CIPHER *evpCipher )
    void EVP_CIPHER_CTX_init( EVP_CIPHER_CTX *ctx )
    int EVP_CIPHER_CTX_cleanup( EVP_CIPHER_CTX *ctx )
    int EVP_CIPHER_CTX_set_padding( EVP_CIPHER_CTX *ctx, int paddingFlag )
    int EVP_CipherInit_ex( EVP_CIPHER_CTX *ctx, EVP_CIPHER *evpCipher, void *engine,
        unsigned char *key, unsigned char *iv, int enc )
    int EVP_CipherUpdate( EVP_CIPHER_CTX *ctx, unsigned char *out,
        int *outl, unsigned char *indata, int inl )
    int EVP_CipherFinal_ex( EVP_CIPHER_CTX *ctx, unsigned char *out,
        int *outl )

    cdef enum :
        EVP_MAX_BLOCK_LENGTH

cdef extern from "Python.h" :
    int PyString_AsStringAndSize( object obj, char **buffer, int *length )
    object PyString_FromStringAndSize( char *buf, int buf_size )
    void *malloc( int size )
    void *realloc( void *ptr, int size )
    void free( void *ptr )

cdef extern from "utils.h" :
    EVP_CIPHER_CTX *AllocCipherContext()
    void FreeCipherContext( EVP_CIPHER_CTX *ptr )

import ncrypt_err

class CipherError( ncrypt_err.BaseLibraryError ) : pass

MODES = ( 'CBC', 'CFB', 'OFB', 'ECB' )
ALGORITHMS = ( 'DES', 'DES-EDE3', 'BF', 'AES-128', 'AES-192', 'AES-256' )

cdef class CipherType :
    cdef EVP_CIPHER *c
    cdef object cipherAlgo, cipherMode

    def __new__( self, cipherAlgo, cipherMode ) :
        self.c = NULL

    def __dealloc__( self ) :
        pass

    def __init__( self, cipherAlgo, cipherMode ) :
        cipherName = '-'.join( [cipherAlgo,cipherMode] )
        self.cipherAlgo = cipherAlgo
        self.cipherMode = cipherMode
        self.c = <EVP_CIPHER *>EVP_get_cipherbyname( cipherName )
        if self.c == NULL :
            raise CipherError, 'unknown cipher: %s' % cipherName

    def algo( self ) : return self.cipherAlgo
    def mode( self ) : return self.cipherMode

    def name( self ) :
        return EVP_CIPHER_name( self.c )

    def blockSize( self ) :
        return EVP_CIPHER_block_size( self.c )

    def keyLength( self ) :
        return EVP_CIPHER_key_length( self.c )

    def ivLength( self ) :
        return EVP_CIPHER_iv_length( self.c )

def EncryptCipher( cipherType, key, iv ) :
    return Cipher( cipherType, key, iv, 1 )

def DecryptCipher( cipherType, key, iv ) :
    return Cipher( cipherType, key, iv, 0 )

cdef class Cipher :
    cdef char *outBuffer
    cdef int outBufferSize
    cdef EVP_CIPHER_CTX *ctx
    cdef int cipherFinalized

    def __new__( self, cipherType, key, iv, encryptFlag ) :
        self.outBuffer = NULL
        self.outBufferSize = 0
        self.ctx = AllocCipherContext()
        EVP_CIPHER_CTX_init( self.ctx )
        self.cipherFinalized = 0

    def __dealloc__( self ) :
        EVP_CIPHER_CTX_cleanup( self.ctx )
        FreeCipherContext( self.ctx )
        free( self.outBuffer )

    def __init__( self, CipherType cipherType not None, key, iv, encryptFlag ) :
        cdef char *keyPtr, *ivPtr
        cdef int keyLen, ivLen, result
        result = PyString_AsStringAndSize( key, &keyPtr, &keyLen )
        if result < 0 :
            raise TypeError, "'key' must be a string"
        if keyLen != cipherType.keyLength() :
            raise CipherError, 'invalid key length %d, expected %d' % (keyLen,cipherType.keyLength())
        if iv is None :
            ivPtr = NULL
            ivLen = 0
        else :
            result = PyString_AsStringAndSize( iv, &ivPtr, &ivLen )
            if result < 0 :
                raise TypeError, "'iv' must be a string"
            if ivLen != cipherType.ivLength() :
                raise CipherError, 'invalid iv length %d, expected %d' % (ivLen,cipherType.ivLength())
        cdef int enc
        if encryptFlag : enc = 1
        else : enc = 0
        result = EVP_CipherInit_ex( self.ctx, cipherType.c, NULL,
                <unsigned char *>keyPtr, <unsigned char *>ivPtr, enc )
        if result == 0 :
            raise CipherError, 'unable to initialize cipher'
        self.cipherFinalized = 0

    def enablePadding( self, padding ) :
        cdef int paddingFlag
        if padding : paddingFlag = 1
        else : paddingFlag = 0
        EVP_CIPHER_CTX_set_padding( self.ctx, paddingFlag )

    cdef void growBuffer( self, int requiredSize ) :
        if requiredSize > self.outBufferSize :
            self.outBuffer = <char *>realloc( self.outBuffer, requiredSize )
            self.outBufferSize = requiredSize

    def update( self, data ) :
        cdef char *inData
        cdef int inDataLen, outDataLen, result
        if self.cipherFinalized :
            raise CipherError, 'cipher operation already completed'
        result = PyString_AsStringAndSize( data, &inData, &inDataLen )
        if result < 0 :
            raise TypeError, 'a string is required'
        if inDataLen == 0 :
            return ''
        self.growBuffer( inDataLen + EVP_MAX_BLOCK_LENGTH )
        outDataLen = self.outBufferSize
        result = EVP_CipherUpdate( self.ctx, <unsigned char *>self.outBuffer,
                &outDataLen, <unsigned char *>inData, inDataLen )
        if result == 0 :
            raise CipherError, 'error in cipher operation'
        return PyString_FromStringAndSize( self.outBuffer, outDataLen )

    cdef object _finish( self ) :
        if self.cipherFinalized :
            raise CipherError, 'cipher operation already completed'
        self.cipherFinalized = 1
        cdef int outDataLen, result
        self.growBuffer( EVP_MAX_BLOCK_LENGTH )
        outDataLen = self.outBufferSize
        result = EVP_CipherFinal_ex( self.ctx, <unsigned char *>self.outBuffer,
                &outDataLen )
        if result == 0 :
            raise CipherError, 'error in cipher operation'
        return PyString_FromStringAndSize( self.outBuffer, outDataLen )

    def finish( self, data=None ) :
        if data is not None :
            return self.update(data) + self._finish()
        else :
            return self._finish()
