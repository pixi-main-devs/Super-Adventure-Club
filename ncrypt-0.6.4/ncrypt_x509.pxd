cdef extern from "openssl/x509.h" :
    ctypedef struct X509

cdef class X509Certificate :
    cdef X509 *x
    cdef int fromX509( self, X509 *xptr )
