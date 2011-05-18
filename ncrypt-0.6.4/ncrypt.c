#include "Python.h"

#include <assert.h>
#include <string.h>

#include <openssl/evp.h>
#include <openssl/ssl.h>

extern void initncrypt_err();
extern void initncrypt_digest();
extern void initncrypt_cipher();
extern void initncrypt_rand();
extern void initncrypt_bignum();
extern void initncrypt_dh();
extern void initncrypt_rsa();
extern void initncrypt_x509();
extern void initncrypt_ssl();

void init_sub_module( PyObject *ncryptMod, char *moduleName, void (*mod_init_func)() ) {
    char fullModName[256], shadowModName[256];
    PyObject *subMod, *allList, *sysModules;
    int result;

    assert( strlen(moduleName) < 100 );
    sprintf( fullModName, "_ncrypt.%s", moduleName );
    sprintf( shadowModName, "ncrypt_%s", moduleName );
    (*mod_init_func)();

    subMod = PyImport_ImportModule( shadowModName );
    assert( subMod );
    result = PyObject_SetAttrString( ncryptMod, moduleName, subMod );
    assert( result == 0 );

    if ( PyObject_HasAttrString(ncryptMod,"__all__") ) {
        PyObject *pyModName;
        allList = PyObject_GetAttrString( ncryptMod, "__all__" );
        assert( allList );
        pyModName = PyString_FromString( moduleName );
        assert( pyModName );
        result = PyList_Append( allList, pyModName );
        assert( result == 0 );
        Py_DECREF( pyModName );
        Py_DECREF( allList );
    }
    else {
        allList = Py_BuildValue( "[s]", moduleName );
        assert( result == 0 );
        result = PyObject_SetAttrString( ncryptMod, "__all__", allList );
        assert( result == 0 );
        Py_DECREF( allList );
    }

    sysModules = PySys_GetObject( "modules" );
    assert( sysModules );
    result = PyDict_SetItemString( sysModules, fullModName, subMod );
    assert( result == 0 );

    Py_DECREF( subMod );
}

PyMODINIT_FUNC init_ncrypt() {
    PyObject *mod;

    OpenSSL_add_all_algorithms();
    OpenSSL_add_ssl_algorithms();
    SSL_load_error_strings();
    EVP_add_cipher_alias( SN_des_ede3_ecb, "DES-EDE3-ECB" );

    mod = Py_InitModule( "_ncrypt", NULL );
    assert( mod );

    init_sub_module( mod, "err", initncrypt_err );
    init_sub_module( mod, "digest", initncrypt_digest );
    init_sub_module( mod, "cipher", initncrypt_cipher );
    init_sub_module( mod, "rand", initncrypt_rand );
    init_sub_module( mod, "bignum", initncrypt_bignum );
    init_sub_module( mod, "dh", initncrypt_dh );
    init_sub_module( mod, "rsa", initncrypt_rsa );
    init_sub_module( mod, "x509", initncrypt_x509 );
    init_sub_module( mod, "ssl", initncrypt_ssl );
}
