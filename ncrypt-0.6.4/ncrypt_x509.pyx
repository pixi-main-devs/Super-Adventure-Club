cimport ncrypt_digest, ncrypt_rsa
from ncrypt_digest cimport EVP_MD
from ncrypt_rsa cimport RSA

import ncrypt_err, ncrypt_rsa

import time, calendar

cdef extern from "openssl/asn1.h" :
    ctypedef struct ASN1_STRING
    ctypedef struct ASN1_OBJECT

    int OBJ_txt2nid( char *s )
    int OBJ_obj2nid( ASN1_OBJECT *x )
    char *OBJ_nid2ln( int n )
    char *OBJ_nid2sn( int n )
    int ASN1_STRING_to_UTF8( unsigned char **out, ASN1_STRING *inp )
    void OPENSSL_free( void *p )

    cdef enum :
        NID_undef

    ctypedef struct ASN1_INTEGER
    void M_ASN1_INTEGER_free( ASN1_INTEGER *ai )
    ctypedef struct ASN1_TIME :
        int length
        int type
        unsigned char *data
        long flags
    ASN1_TIME *ASN1_TIME_set( ASN1_TIME *t, long seconds )
    ctypedef struct ASN1_GENERALIZEDTIME :
        int length
        int type
        unsigned char *data
        long flags
    void ASN1_GENERALIZEDTIME_free( ASN1_GENERALIZEDTIME *t )
    ASN1_GENERALIZEDTIME *ASN1_GENERALIZEDTIME_set( ASN1_GENERALIZEDTIME *t, long seconds )
    ASN1_GENERALIZEDTIME *ASN1_TIME_to_generalizedtime( ASN1_TIME *t, ASN1_GENERALIZEDTIME **gt )

cdef extern from "openssl/bio.h" :
    ctypedef struct BIO_METHOD
    ctypedef struct BIO
    BIO_METHOD *BIO_s_mem()
    BIO *BIO_new( BIO_METHOD *m )
    int BIO_free( BIO *b )
    int BIO_write( BIO *b, void *buf, int num )

cdef extern from "openssl/bn.h" :
    ctypedef struct BIGNUM
    BIGNUM *BN_new()
    void BN_free( BIGNUM *bn )
    BIGNUM *ASN1_INTEGER_to_BN( ASN1_INTEGER *ai, BIGNUM *bn )
    ASN1_INTEGER *BN_to_ASN1_INTEGER( BIGNUM *bn, ASN1_INTEGER *ai )

cdef extern from "utils.h" :
    object BNToLong( BIGNUM *bn )
    int LongToBN( object x, BIGNUM *bn )
    object GetBIOData( BIO *b )

cdef extern from "openssl/rsa.h" :
    void RSA_free( RSA *x )
    RSA *RSAPublicKey_dup( RSA *x )

cdef extern from "openssl/evp.h" :
    ctypedef struct EVP_PKEY :
        int type
    EVP_PKEY *EVP_PKEY_new()
    void EVP_PKEY_free( EVP_PKEY *x )
    int EVP_PKEY_type( int type )
    RSA *EVP_PKEY_get1_RSA( EVP_PKEY *x )
    int EVP_PKEY_set1_RSA( EVP_PKEY *pk, RSA *r )

    cdef enum :
        EVP_PKEY_RSA

cdef extern from "openssl/x509.h" :
    ctypedef struct X509_NAME_ENTRY
    ctypedef struct X509_NAME
    X509_NAME *X509_NAME_new()
    void X509_NAME_free( X509_NAME *x )
    X509_NAME *X509_NAME_dup( X509_NAME *x )
    int X509_NAME_entry_count( X509_NAME *x )
    int X509_NAME_add_entry_by_txt( X509_NAME *x, char *fieldName, int type,
            unsigned char *fieldValue, int len, int loc, int set )
    X509_NAME_ENTRY *X509_NAME_get_entry( X509_NAME *x, int loc )
    ASN1_OBJECT *X509_NAME_ENTRY_get_object( X509_NAME_ENTRY *x )
    ASN1_STRING *X509_NAME_ENTRY_get_data( X509_NAME_ENTRY *x )

    X509 *X509_new()
    void X509_free( X509 *x )
    X509 *X509_dup( X509 *x )
    long X509_get_version( X509 *x )
    int X509_set_version( X509 *x, long version )
    ASN1_INTEGER *X509_get_serialNumber( X509 *x )
    int X509_set_serialNumber( X509 *x, ASN1_INTEGER *sn )
    X509_NAME *X509_get_issuer_name( X509 *x )
    int X509_set_issuer_name( X509 *x, X509_NAME *issuer )
    X509_NAME *X509_get_subject_name( X509 *x )
    int X509_set_subject_name( X509 *x, X509_NAME *subject )
    EVP_PKEY *X509_get_pubkey( X509 *x )
    int X509_set_pubkey( X509 *x, EVP_PKEY *pk )
    ASN1_TIME *X509_get_notBefore( X509 *x )
    ASN1_TIME *X509_get_notAfter( X509 *x )
    int X509_sign( X509 *x, EVP_PKEY *pk, EVP_MD *md )
    int i2d_X509( X509 *x, unsigned char **out )
    X509 *d2i_X509( X509 **px, unsigned char **inp, int len )

    cdef enum :
        MBSTRING_ASC

cdef extern from "openssl/pem.h" :
    int PEM_write_bio_X509( BIO *b, X509 *x )
    X509 *PEM_read_bio_X509( BIO *b, void *, void *, void * )

cdef extern from "Python.h" :
    ctypedef struct PyObject
    void Py_DECREF( PyObject *obj )
    void Py_INCREF( PyObject *obj )
    PyObject *Raw_PyString_FromStringAndSize "PyString_FromStringAndSize" ( char *s, int len )
    char *Raw_PyString_AsString "PyString_AsString" ( PyObject *s )
    int _PyString_Resize( PyObject **s, int newsize )
    object PyString_FromStringAndSize( char *s, int len )
    object PyString_FromString( char *s )
    int PyString_AsStringAndSize( object obj, char **buffer, int *length )

class X509Error( ncrypt_err.BaseLibraryError ) : pass

cdef class X509Name :
    cdef X509_NAME *xn

    def __new__( self ) :
        self.xn = NULL

    def __dealloc__( self ) :
        if self.xn :
            X509_NAME_free( self.xn )

    def __init__( self ) :
        cdef X509_NAME *newxn
        newxn = X509_NAME_new()
        if not newxn :
            raise X509Error, 'unable to allocate X509_NAME structure'
        if self.xn : X509_NAME_free( self.xn )
        self.xn = newxn

    cdef int fromX509_NAME( self, X509_NAME *xnptr ) :
        cdef X509_NAME *newxn
        newxn = X509_NAME_dup( xnptr )
        if not newxn :
            return 0
        if self.xn : X509_NAME_free( self.xn )
        self.xn = newxn
        return 1

    def entryCount( self ) :
        return X509_NAME_entry_count( self.xn )

    def addEntry( self, char *fieldName, char *fieldValue ) :
        cdef int result
        result = X509_NAME_add_entry_by_txt( self.xn, fieldName, MBSTRING_ASC,
                <unsigned char *>fieldValue, -1, -1, 0 )
        if not result :
            raise X509Error, 'unable to add name entry'

    def getEntry( self, int index ) :
        cdef X509_NAME_ENTRY *e
        e = X509_NAME_get_entry( self.xn, index )
        if not e :
            raise X509Error, 'no entry available at index %d' % index
        cdef ASN1_OBJECT *keyObj
        cdef int keyNid
        keyObj = X509_NAME_ENTRY_get_object( e )
        keyNid = OBJ_obj2nid( keyObj )
        cdef char *keyStr
        keyStr = <char *>OBJ_nid2ln( keyNid )
        if not keyStr :
            keyStr = <char *>OBJ_nid2sn( keyNid )
            if not keyStr :
                raise X509Error, 'unable to get field name for entry'
        key = PyString_FromString( keyStr )
        cdef ASN1_STRING *valueObj
        valueObj = X509_NAME_ENTRY_get_data( e )
        cdef char *valueStr
        cdef int result
        result = ASN1_STRING_to_UTF8( <unsigned char **>&valueStr, valueObj )
        if result < 0 :
            raise X509Error, 'unable to get field value for entry'
        try :
            value = PyString_FromStringAndSize( valueStr, result )
        finally :
            OPENSSL_free( valueStr )
        return (key,value)

    def lookupEntry( self, fieldName ) :
        cdef int i, n
        i = 0
        n = self.entryCount()
        while i < n :
            (k,v) = self.getEntry( i )
            if k == fieldName :
                return v
            i = i + 1
        raise X509Error, 'unable to find field name: %s' % fieldName

cdef class X509Certificate :
    def __new__( self, data=None ) :
        self.x = NULL

    def __dealloc__( self ) :
        if self.x :
            X509_free( self.x )

    def __init__( self, data=None ) :
        cdef X509 *newx
        if data is not None :
            self.fromDER( data )
        else :
            newx = X509_new()
            if not newx :
                raise X509Error, 'unable to allocate X509 structure'
            if self.x : X509_free( self.x )
            self.x = newx

    cdef int fromX509( self, X509 *xptr ) :
        cdef X509 *newx
        newx = X509_dup( xptr )
        if not newx :
            return 0
        if self.x : X509_free( self.x )
        self.x = newx
        return 1

    def getVersion( self ) :
        return <int>X509_get_version( self.x )

    def setVersion( self, int version ) :
        X509_set_version( self.x, <long>version )

    def getSerialNumber( self ) :
        cdef ASN1_INTEGER *sn
        cdef BIGNUM *bn
        sn = X509_get_serialNumber( self.x )
        bn = ASN1_INTEGER_to_BN( sn, NULL )
        try :
            return BNToLong( bn )
        finally :
            BN_free( bn )

    def setSerialNumber( self, serialNumber ) :
        cdef int result
        cdef BIGNUM *bn
        cdef ASN1_INTEGER *sn
        bn = BN_new()
        sn = NULL
        try :
            result = LongToBN( serialNumber, bn )
            if result < 0 :
                raise TypeError, 'serial number must be int/long'
            sn = BN_to_ASN1_INTEGER( bn, NULL )
            if not sn :
                raise X509Error, 'unable to set serial number'
            result = X509_set_serialNumber( self.x, sn )
            if not result :
                raise X509Error, 'unable to set serial number'
        finally :
            BN_free( bn )
            if sn != NULL :
                M_ASN1_INTEGER_free( sn )

    def getIssuer( self ) :
        cdef X509_NAME *issuer
        issuer = X509_get_issuer_name( self.x )
        cdef X509Name xn
        cdef int result
        xn = X509Name()
        result = xn.fromX509_NAME( issuer )
        if not result :
            raise X509Error, 'unable to get issuer'
        return xn

    def setIssuer( self, X509Name xn not None ) :
        cdef X509_NAME *issuer
        issuer = X509_NAME_dup( xn.xn )
        if not issuer :
            raise X509Error, 'unable to copy X509_NAME'
        cdef int result
        try :
            result = X509_set_issuer_name( self.x, issuer )
            if not result :
                raise X509Error, 'unable to set issuer'
        finally :
            X509_NAME_free( issuer )

    def getSubject( self ) :
        cdef X509_NAME *subject
        subject = X509_get_subject_name( self.x )
        cdef X509Name xn
        cdef int result
        xn = X509Name()
        result = xn.fromX509_NAME( subject )
        if not result :
            raise X509Error, 'unable to get subject'
        return xn

    def setSubject( self, X509Name xn not None ) :
        cdef X509_NAME *subject
        subject = X509_NAME_dup( xn.xn )
        if not subject :
            raise X509Error, 'unable to copy X509_NAME'
        cdef int result
        try :
            result = X509_set_subject_name( self.x, subject )
            if not result :
                raise X509Error, 'unable to set subject'
        finally :
            X509_NAME_free( subject )

    def getPublicKey( self ) :
        cdef EVP_PKEY *pk
        pk = X509_get_pubkey( self.x )
        if not pk :
            raise X509Error, 'unable to get public key'
        cdef int pkType
        cdef RSA *r
        r = NULL
        cdef ncrypt_rsa.RSAKey rsaKey
        try :
            pkType = EVP_PKEY_type( pk.type )
            if pkType != EVP_PKEY_RSA :
                raise X509Error, 'unsupported public key type, only RSA supported'
            r = EVP_PKEY_get1_RSA( pk )
            if not r :
                raise X509Error, 'unable to get RSA public key'
            rsaKey = ncrypt_rsa.RSAKey()
            rsaKey.loadCPublicKey( r )
            return rsaKey
        finally :
            EVP_PKEY_free( pk )
            if r != NULL :
                RSA_free( r )

    def setPublicKey( self, ncrypt_rsa.RSAKey rsaKey not None ) :
        if not rsaKey.hasPublicKey() :
            raise X509Error, 'invalid public key'
        cdef RSA *r
        cdef EVP_PKEY *pk
        pk = NULL
        cdef int result
        r = RSAPublicKey_dup( rsaKey.rsa )
        if not r :
            raise X509Error, 'unable to copy RSA public key'
        try :
            pk = EVP_PKEY_new()
            if not pk :
                raise X509Error, 'unable to allocate EVP_PKEY structure'
            result = EVP_PKEY_set1_RSA( pk, r )
            assert result != 0
            result = X509_set_pubkey( self.x, pk )
            assert result != 0
        finally :
            RSA_free( r )
            if pk != NULL :
                EVP_PKEY_free( pk )

    def getNotBefore( self ) :
        cdef ASN1_GENERALIZEDTIME *gt
        gt = ASN1_TIME_to_generalizedtime( X509_get_notBefore(self.x), NULL )
        if not gt :
            raise X509Error, 'invalid time value'
        try :
            s = PyString_FromStringAndSize( <char *>gt.data, gt.length )
            if len(s) != 15 :
                raise X509Error, 'invalid time data length'
            if s[-1] != 'Z' :
                raise X509Error, 'invalid time data'
            f = '%Y%m%d%H%M%S'
            return calendar.timegm( time.strptime(s[:-1],f) )
        finally :
            ASN1_GENERALIZEDTIME_free( gt )

    def setNotBefore( self, long seconds ) :
        cdef ASN1_TIME *t
        t = ASN1_TIME_set( X509_get_notBefore(self.x), seconds )
        if not t :
            raise X509Error, 'unable to set time'

    def getNotAfter( self ) :
        cdef ASN1_GENERALIZEDTIME *gt
        gt = ASN1_TIME_to_generalizedtime( X509_get_notAfter(self.x), NULL )
        if not gt :
            raise X509Error, 'invalid time value'
        try :
            s = PyString_FromStringAndSize( <char *>gt.data, gt.length )
            if len(s) != 15 :
                raise X509Error, 'invalid time data length'
            if s[-1] != 'Z' :
                raise X509Error, 'invalid time data'
            f = '%Y%m%d%H%M%S'
            return calendar.timegm( time.strptime(s[:-1],f) )
        finally :
            ASN1_GENERALIZEDTIME_free( gt )

    def setNotAfter( self, long seconds ) :
        cdef ASN1_TIME *t
        t = ASN1_TIME_set( X509_get_notAfter(self.x), seconds )
        if not t :
            raise X509Error, 'unable to set time'

    def sign( self, ncrypt_rsa.RSAKey rsaKey not None,
            ncrypt_digest.DigestType digestType not None ) :
        if not rsaKey.hasPrivateKey() :
            raise X509Error, 'private key not initialized'
        cdef EVP_PKEY *pk
        cdef int result
        pk = EVP_PKEY_new()
        if not pk :
            raise X509Error, 'unable to allocate EVP_PKEY structure'
        try :
            result = EVP_PKEY_set1_RSA( pk, rsaKey.rsa )
            if not result :
                raise X509Error, 'error in initializing key'
            result = X509_sign( self.x, pk, digestType.m )
            if not result :
                raise X509Error, 'error in signing certificate'
        finally :
            EVP_PKEY_free( pk )

    def fromDER( self, data ) :
        cdef X509 *newx
        cdef char *p
        cdef int dataLen, result
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        newx = d2i_X509( NULL, <unsigned char **>&p, dataLen )
        if not newx :
            raise X509Error, 'unable to load object from data'
        if self.x : X509_free( self.x )
        self.x = newx

    def toDER( self ) :
        cdef int len, len1
        cdef PyObject *derStr
        len = i2d_X509( self.x, NULL )
        if len < 0 :
            raise X509Error, 'error in cert data'
        derStr = Raw_PyString_FromStringAndSize( NULL, len )
        if derStr == NULL :
            raise MemoryError, 'unable to allocate string'
        cdef char *p
        p = Raw_PyString_AsString( derStr )
        try :
            len1 = i2d_X509( self.x, <unsigned char **>&p )
            assert len == len1
            return <object>derStr
        finally :
            Py_DECREF( derStr )

    def fromPEM( self, data ) :
        cdef char *p
        cdef int dataLen, result
        cdef BIO *b
        cdef X509 *newx
        result = PyString_AsStringAndSize( data, &p, &dataLen )
        if result < 0 :
            raise TypeError, 'a string is expected'
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise X509Error, 'unable to allocate BIO structure'
        try :
            result = BIO_write( b, p, dataLen )
            if result < 0 :
                raise X509Error, 'unable to write data to BIO'
            newx = PEM_read_bio_X509( b, NULL, NULL, NULL )
            if not newx :
                raise X509Error, 'unable to load object from data'
            if self.x : X509_free( self.x )
            self.x = newx
        finally :
            BIO_free( b )

    def toPEM( self ) :
        cdef int result
        cdef BIO *b
        b = BIO_new( BIO_s_mem() )
        if not b :
            raise X509Error, 'unable to allocate a BIO structure'
        try :
            result = PEM_write_bio_X509( b, self.x )
            if not result :
                raise X509Error, 'error in cert data'
            ret = GetBIOData( b )
            if ret is None :
                raise X509Error, 'error in creating PEM data'
            return ret
        finally :
            BIO_free( b )
