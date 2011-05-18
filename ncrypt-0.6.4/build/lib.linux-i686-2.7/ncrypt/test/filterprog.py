import sys, os, getopt

def usage( otherOptsHelp ) :
    progName = os.path.split(sys.argv[0])[1]
    if otherOptsHelp :
        print 'Usage: %s %s [-o outfile] [infile]' % (progName,otherOptsHelp)
    else :
        print 'Usage: %s [-o outfile] [infile]' % progName

def main( callback, otherOpts='', otherOptsHelp='', longOpts=None ) :
    otherArgs = {}
    longOptsList = longOpts
    if longOptsList is None : longOptsList = []
    try :
        opts, args = getopt.getopt( sys.argv[1:], 'o:'+otherOpts, longOptsList )
    except getopt.GetoptError, s :
        print 'Error: %s' % s
        usage( otherOptsHelp )
        return
    inFile = None
    outFile = None
    if len(args) > 1 :
        print 'Too many arguments provided'
        usage( otherOptsHelp )
        return
    if len(args) == 1 :
        try :
            inFile = file( args[0], 'rb' )
        except IOError :
            print 'Unable to open input file:', args[0]
            usage( otherOptsHelp )
            return
    for o,a in opts :
        if o == '-o' :
            try :
                outFile = file( a, 'wb' )
            except IOError :
                print 'Unable to open output file:', a
                usage( otherOptsHelp )
                return
        else :
            otherArgs[o] = a
    if not inFile : inFile = sys.stdin
    if not outFile : outFile = sys.stdout
    callback( inFile, outFile, otherArgs )

def echoTest( inFile, outFile, args ) :
    while True :
        data = inFile.read( 1024 )
        if not data : break
        outFile.write( data )
    outFile.close()
    inFile.close()

if __name__ == '__main__' :
    main( echoTest )
