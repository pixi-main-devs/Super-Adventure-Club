cdef extern from "openssl/evp.h" :
    ctypedef struct EVP_MD_CTX
    ctypedef struct EVP_MD
    EVP_MD *EVP_get_digestbyname( char *name )
    void EVP_add_digest( EVP_MD *evpMd )
    void EVP_add_digest_alias( char *realName, char *aliasName )
    int EVP_MD_type( EVP_MD *evpMd )
    char *EVP_MD_name( EVP_MD *evpMd )
    int EVP_MD_size( EVP_MD *evpMd )
    int EVP_MD_block_size( EVP_MD *evpMd )
    EVP_MD_CTX *EVP_MD_CTX_create()
    void EVP_MD_CTX_destroy( EVP_MD_CTX *ctx )
    int EVP_DigestInit_ex( EVP_MD_CTX *ctx, EVP_MD *mdType, void *engine )
    int EVP_DigestUpdate( EVP_MD_CTX *ctx, void *data, unsigned int dataLen )
    int EVP_DigestFinal_ex( EVP_MD_CTX *ctx, unsigned char *md, unsigned int *mdLen )
    
    cdef enum :
        EVP_MAX_MD_SIZE
    
cdef extern from "Python.h" :
    int PyString_AsStringAndSize( object obj, char **buffer, int *length )
    object PyString_FromStringAndSize( char *buf, int buf_size )

cdef extern from "utils.h" :
    void HexEncode( void *src, int srcLen, void *dest, int destLen )
    void HexDecode( void *src, int srcLen, void *dest, int destLen )

import ncrypt_err

class DigestError( ncrypt_err.BaseLibraryError ): pass

ALGORITHMS = ('MD5','SHA1','SHA224','SHA256','SHA384','SHA512')

cdef class DigestType :
    def __new__( self, evpMd ) :
        self.m = NULL

    def __dealloc__( self ) :
        pass

    def __init__( self, evpMd ) :
        self.m = <EVP_MD *>EVP_get_digestbyname( evpMd )
        if self.m == NULL :
            raise DigestError, 'unknown digest: %s' % evpMd

    def name( self ) :
        return EVP_MD_name( self.m )

    def size( self ) :
        return EVP_MD_size( self.m )

    def blockSize( self ) :
        return EVP_MD_block_size( self.m )

    def nid( self ) :
        return EVP_MD_type( self.m )

cdef class Digest :
    cdef EVP_MD_CTX *ctx
    cdef int digestFinalized
    cdef readonly object digestType

    def __new__( self, digestType ) :
        self.ctx = NULL
        self.digestFinalized = 0

    cdef void cleanupCtx( self ) :
        if self.ctx != NULL :
            EVP_MD_CTX_destroy( self.ctx )
            self.ctx = NULL
            self.digestFinalized = 0

    def __dealloc__( self ) :
        self.cleanupCtx()

    def __init__( self, DigestType digestType not None ) :
        self.cleanupCtx()
        self.ctx = EVP_MD_CTX_create()
        cdef int result
        result = EVP_DigestInit_ex( self.ctx, digestType.m, NULL )
        if result != 1 :
            raise DigestError, 'unable to initialize digest'
        self.digestType = digestType

    def update( self, data ) :
        if self.digestFinalized != 0 :
            raise DigestError, 'no further update() operations allowed'
        cdef char *s
        cdef int slen
        cdef int result
        result = PyString_AsStringAndSize( data, &s, &slen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        result = EVP_DigestUpdate( self.ctx, s, slen )
        if result != 1 :
            raise DigestError, 'unable to update digest'

    def digest( self, data=None ) :
        if self.digestFinalized != 0 :
            raise DigestError, 'digest operation is already completed'
        if data is not None :
            self.update( data )
        cdef unsigned char md[EVP_MAX_MD_SIZE]
        cdef unsigned int mdLen
        cdef int result
        result = EVP_DigestFinal_ex( self.ctx, md, &mdLen )
        if result != 1 :
            raise DigestError, 'unable to finalize digest'
        self.digestFinalized = 1
        return PyString_FromStringAndSize( <char *>md, <int>mdLen )
