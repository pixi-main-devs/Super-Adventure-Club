#include <assert.h>

#include "utils.h"

static unsigned char hexTab[] = "0123456789abcdef";

void HexEncode( const void *src, int srcLen, void *dest, int destLen ) {
    const unsigned char *a = (const unsigned char *)src;
    unsigned char *b = (unsigned char *)dest;
    assert( destLen >= 2*srcLen );
    for ( ; srcLen; --srcLen ) {
        *(b++) = hexTab[(*a) >> 4];
        *(b++) = hexTab[(*a) & 0xF];
        ++a;
    }
}

#define HEX2CHAR(c) \
(((c >= '0') && (c <= '9')) ? (c-'0') : \
    ((c >= 'a') && (c <= 'f')) ? (c+10-'a') : \
    ((c >= 'A') && (c <= 'F')) ? (c+10-'A') : -1)

// srcLen must be even
// destLen must be >= srcLen/2
int HexDecode( const void *src, int srcLen, void *dest, int destLen ) {
    const unsigned char *a = (const unsigned char *)src;
    unsigned char *b = (unsigned char *)dest;
    int x;
    assert( srcLen % 2 == 0 );
    assert( destLen >= srcLen/2 );
    for ( ; srcLen; srcLen-=2 ) {
        x = (HEX2CHAR(a[0]) << 4) | HEX2CHAR(a[1]);
        if ( x >> 8 ) return -1;
        *(b++) = (unsigned char)x;
        a += 2;
    }
    return 0;
}

EVP_CIPHER_CTX *AllocCipherContext() {
    return (EVP_CIPHER_CTX *)OPENSSL_malloc( sizeof(EVP_CIPHER_CTX) );
}

void FreeCipherContext( EVP_CIPHER_CTX *ptr ) {
    OPENSSL_free( ptr );
}

PyObject *BNToLong( BIGNUM *bn ) {
    char *s = BN_bn2dec( bn );
    PyObject *x = PyLong_FromString( s, NULL, 10 );
    OPENSSL_free( s );
    return x;
}

int LongToBN( PyObject *x, BIGNUM *bn ) {
    PyObject *s;
    int result;
    if ( (!PyLong_Check(x)) && (!PyInt_Check(x)) ) {
        return -1;
    }
    s = PyObject_Str( x );
    result = BN_dec2bn( &bn, PyString_AsString(s) );
    Py_DECREF( s );
    if ( result == 0 ) return -1;
    return 0;
}

PyObject *GetBIOData( BIO *b ) {
    char *p;
    long size = BIO_get_mem_data( b, &p );
    if ( size < 0 ) {
        Py_INCREF( Py_None );
        return Py_None;
    }
    return PyString_FromStringAndSize( p, size );
}
