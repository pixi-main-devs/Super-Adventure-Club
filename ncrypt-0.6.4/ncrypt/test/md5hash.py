import sys
from ncrypt import digest

def main() :
    if len(sys.argv) != 2 :
        print 'usage: md5hash <file>'
        return
    fileName = sys.argv[1]
    dt = digest.DigestType( 'MD5' )
    d = digest.Digest( dt )
    hash = d.digest( file(sys.argv[1],'rb').read() )
    print hash.encode('hex')

if __name__ == '__main__' :
    main()
