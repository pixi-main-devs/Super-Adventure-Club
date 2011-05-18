cdef extern from "openssl/dh.h" :
    ctypedef struct BIGNUM
    ctypedef struct DH_s "DH" :
        int pad
        int version
        BIGNUM *p
        BIGNUM *g
        long length
        BIGNUM *pub_key
        BIGNUM *priv_key

cdef class DH :
    cdef DH_s *dh
