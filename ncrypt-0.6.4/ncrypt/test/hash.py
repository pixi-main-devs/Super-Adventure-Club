from ncrypt import digest
import filterprog

def filterMain( inFile, outFile, args ) :
    digestName = args.get( '-h', 'MD5' )
    try :
        digestType = digest.DigestType( digestName )
    except digest.DigestError :
        print 'Unknown digest: %s' % digestName
        return

    d = digest.Digest( digestType )

    while 1 :
        data = inFile.read( 1024 )
        if not data : break
        d.update( data )
    print>>outFile, d.digest().encode('hex')
    inFile.close()
    outFile.close()

if __name__ == '__main__' :
    filterprog.main( filterMain, 'h:', '[-h <hash-func>]' )
