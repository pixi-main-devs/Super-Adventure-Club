cdef extern from "openssl/bn.h" :
    ctypedef struct BIGNUM
    BIGNUM *BN_new()
    void BN_free( BIGNUM *x )
    void BN_clear( BIGNUM *x )
    int BN_dec2bn( BIGNUM **x, char *str )
    char *BN_bn2dec( BIGNUM *x )
    int BN_num_bytes( BIGNUM *x )
    int BN_num_bits( BIGNUM *x )

cdef extern from "openssl/crypto.h" :
    void OPENSSL_free( void *p )

cdef extern from "Python.h" :
    int PyString_Check( object obj )
    int PyInt_Check( object obj )
    int PyLong_Check( object obj )
    char *PyString_AsString( object obj )
    int PyString_AsStringAndSize( object obj, char **buffer, int *length )
    object PyString_FromStringAndSize( char *buf, int buf_size )
    object Py_BuildValue( char *fmt, ... )
    object PyObject_Str( object obj )
    object PyLong_FromString( char *p, char **pend, int base )

cdef extern from "stdlib.h" :
    void *malloc( int size )
    void free( void *p )

cdef class BigNum :
    cdef BIGNUM *bn

    def __new__( self, x=None ) :
        self.bn = BN_new()

    cdef _free( self ) :
        BN_free( self.bn )
        self.bn = NULL

    def __dealloc__( self ) :
        self._free()

    def __init__( self, x=None ) :
        if PyInt_Check(x) or PyLong_Check(x) :
            x = PyObject_Str( x )
        cdef char *s
        cdef int result
        if PyString_Check(x) :
            s = PyString_AsString(x)
            result = BN_dec2bn( &self.bn, s )
            if result == 0 :
                raise ValueError, 'invalid string value passed'
        elif x is not None :
            raise TypeError, 'invalid type passed, require int/long/str'

    def clear( self ) :
        BN_clear( self.bn )

    def toLong( self ) :
        cdef char *s
        s = BN_bn2dec( self.bn )
        try :
            return PyLong_FromString( s, NULL, 10 )
        finally :
            OPENSSL_free( s )

    def fromLong( self, x ) :
        if not PyLong_Check(x) and not PyInt_Check(x) :
            raise TypeError, 'long/int type required'
        x = PyObject_Str( x )
        cdef char *s
        cdef int result
        s = PyString_AsString( x )
        result = BN_dec2bn( &self.bn, s )
        if result == 0 :
            raise ValueError, 'invalid string value passed'

    def numBytes( self ) :
        return BN_num_bytes( self.bn )

    def numBits( self ) :
        return BN_num_bits( self.bn )
