cdef extern from "openssl/err.h" :
    unsigned long ERR_get_error()
    unsigned long ERR_peek_error()
    char *ERR_lib_error_string( unsigned long e )
    char *ERR_func_error_string( unsigned long e )
    char *ERR_reason_error_string( unsigned long e )
    void ERR_clear_error()

cdef extern from "Python.h" :
    object PyString_FromString( char *p )

cdef object MakePyString( char *p ) :
    if not p : return ''
    return PyString_FromString( p )

cdef object buildErrorTuple( unsigned long errCode ) :
    cdef char *libStr, *funcStr, *reasonStr
    libStr = <char *>ERR_lib_error_string( errCode )
    funcStr = <char *>ERR_func_error_string( errCode )
    reasonStr = <char *>ERR_reason_error_string( errCode )
    return ( errCode, MakePyString(libStr),
            MakePyString(funcStr), MakePyString(reasonStr) )

def getError() :
    return buildErrorTuple( ERR_get_error() )

def peekError() :
    return buildErrorTuple( ERR_peek_error() )

def clearErrors() :
    ERR_clear_error()

class BaseError( Exception ) :
    def __init__( self, *args ) :
        Exception.__init__( self, *args )

class LibraryErrorInfo :
    def initErrorInfo( self ) :
        cdef unsigned long errCode
        (self.errorCode, self.errorLib, self.errorFunc, self.errorReason) = getError()
        self.nestedErrors = []
        while ERR_peek_error() != 0 :
            self.nestedErrors.append( getError() )

    def updateArgs( self, args ) :
        reason = self.getReason()
        if (len(args) == 1) and isinstance(args[0],str) and reason :
            args = ( '%s (%s)' % (args[0],reason), )
        return args

    def getCode( self ) : return self.errorCode
    def getLib( self ) : return self.errorLib
    def getFunc( self ) : return self.errorFunc
    def getReason( self ) : return self.errorReason
    def getError( self ) : return (self.errorCode, self.errorLib, self.errorFunc, self.errorReason)
    def getNestedErrors( self ) : return self.nestedErrors

class BaseLibraryError( BaseError, LibraryErrorInfo ) :
    def __init__( self, *args ) :
        LibraryErrorInfo.initErrorInfo( self )
        args = self.updateArgs( args )
        BaseError.__init__( self, *args )
