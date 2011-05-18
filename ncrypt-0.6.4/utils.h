#ifndef _ncrypt_utils_h
#define _ncrypt_utils_h

#include <openssl/bn.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <Python.h>

// destLen must be >= 2*srcLen
void HexEncode( const void *src, int srcLen, void *dest, int destLen );

// srcLen must be even
// destLen must be >= srcLen/2
int HexDecode( const void *src, int srcLen, void *dest, int destLen );

EVP_CIPHER_CTX *AllocCipherContext();
void FreeCipherContext( EVP_CIPHER_CTX *ptr );

PyObject *BNToLong( BIGNUM *bn );
int LongToBN( PyObject *x, BIGNUM *bn );

PyObject *GetBIOData( BIO *b );

#endif
