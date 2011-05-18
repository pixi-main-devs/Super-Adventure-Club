from ncrypt import cipher
import filterprog

otherOptsHelp = '[-c <cipher>] [-m <mode>] [--nopadding] -k <keyfile>'
def usage() :
    filterprog.usage( otherOptsHelp )

def filterMain( inFile, outFile, args ) :
    cipherName = args.get( '-c', 'DES-EDE3' )
    modeName = args.get( '-m', 'CBC' )
    fullName = '-'.join( [cipherName,modeName] )
    try :
        cipherType = cipher.CipherType( fullName )
    except cipher.CipherError :
        print 'Unknown cipher: %s' % fullName
        usage()
        return

    keyFile = args.get( '-k', 'key.file' )
    try :
        key = file(keyFile,'rb').read()
    except IOError :
        print 'Unable to open key file: %s' % keyFile
        usage()
        return

    try :
        c = cipher.DecryptCipher( cipherType, key, None )
    except cipher.CipherError, s :
        print 'Error: %s' % s
        usage()
        return

    paddingEnabled = not args.has_key('--nopadding')
    c.enablePadding( paddingEnabled )

    while 1 :
        data = inFile.read( 1024 )
        if not data : break
        data = c.update( data )
        outFile.write( data )
    data = c.finish()
    outFile.write( data )
    inFile.close()
    outFile.close()

if __name__ == '__main__' :
    filterprog.main( filterMain, 'c:m:k:', otherOptsHelp, ['nopadding'] )
