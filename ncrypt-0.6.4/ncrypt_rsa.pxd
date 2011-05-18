cdef extern from "openssl/rsa.h" :
    ctypedef struct BIGNUM
    ctypedef struct RSA :
        int pad
        long version
        void *meth
        void *engine
        BIGNUM *n
        BIGNUM *e
        BIGNUM *d
        BIGNUM *p
        BIGNUM *q
        BIGNUM *dmp1
        BIGNUM *dmq1
        BIGNUM *iqmp

cdef class RSAKey :
    cdef RSA *rsa
    cdef void loadCPublicKey( self, RSA *r )
    cdef void loadCPrivateKey( self, RSA *r )
