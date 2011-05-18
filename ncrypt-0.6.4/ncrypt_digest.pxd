cdef extern from "openssl/evp.h" :
    ctypedef struct EVP_MD

cdef class DigestType :
    cdef EVP_MD *m
