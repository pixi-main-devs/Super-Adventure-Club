cdef extern from "openssl/rand.h" :
    int RAND_bytes( unsigned char *buf, int num )
    int RAND_pseudo_bytes( unsigned char *buf, int num )
    void RAND_add( void *buf, int num, double entropy )
    void RAND_seed( void *buf, int num )
    int RAND_status()

cdef extern from "Python.h" :
    int PyString_AsStringAndSize( object obj, char **buffer, int *length )
    object PyString_FromStringAndSize( char *buf, int buf_size )
    object Py_BuildValue( char *fmt, ... )

cdef extern from "stdlib.h" :
    void *malloc( int size )
    void free( void *p )

import ncrypt_err

class RandError( ncrypt_err.BaseLibraryError ) : pass

def bytes( int num, int checkResult=0 ) :
    cdef char *buf
    cdef int result
    if num <= 0 :
        raise ValueError, "'num' should be > 0"
    buf = <char *>malloc( num )
    try :
        result = RAND_bytes( <unsigned char *>buf, num )
        if checkResult and (result == 0) :
            raise RandError, 'RNG not seeded sufficiently'
        return PyString_FromStringAndSize( buf, num )
    finally :
        free( buf )

def pseudoBytes( int num ) :
    cdef char *buf
    if num <= 0 :
        raise ValueError, "'num' should be > 0"
    buf = <char *>malloc( num )
    try :
        RAND_pseudo_bytes( <unsigned char *>buf, num )
        return PyString_FromStringAndSize( buf, num )
    finally :
        free( buf )

def seed( data, entropy=None ) :
    cdef char *ptr
    cdef int size, result
    result = PyString_AsStringAndSize( data, &ptr, &size )
    if result < 0 :
        raise TypeError, 'a string is expected'
    if entropy is None :
        RAND_seed( ptr, size )
    else :
        RAND_add( ptr, size, entropy )

def status() :
    return RAND_status()
