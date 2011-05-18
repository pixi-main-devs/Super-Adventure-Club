import sys, os, unittest, md5, sha
from ncrypt import digest

md5Type = digest.DigestType( 'MD5' )
sha1Type = digest.DigestType( 'SHA1' )

def doMD5( data ) :
    return digest.Digest(md5Type).digest( data )

def doSHA1( data ) :
    return digest.Digest(sha1Type).digest( data )

class DigestTestCase( unittest.TestCase ) :
    def setUp( self ) :
        self.dtList = [digest.DigestType(algo) for algo in digest.ALGORITHMS]
        self.dtMap = dict( zip(digest.ALGORITHMS,self.dtList) )

    def testMD5( self ) :
        self.assertEquals( doMD5('hi'), md5.md5('hi').digest() )

    def testSHA1( self ) :
        self.assertEquals( doSHA1('hi'), sha.sha('hi').digest() )

    def testNames( self ) :
        for (k,v) in self.dtMap.items() : self.assertEquals( k, v.name() )

    def testInfo( self ) :
        dtInfo = [(dt.name(),dt.blockSize(),dt.size()*8,dt.nid()) for dt in self.dtList]

    def testDigests( self ) :
        s = ''
        for i in range(1000) :
            for dt in self.dtList :
                d = digest.Digest(dt)
                dv = d.digest(s)
                self.assertEquals( len(dv), dt.size() )
                if dt.name() == 'MD5' :
                    self.assertEquals( dv, md5.md5(s).digest() )
                elif dt.name() == 'SHA1' :
                    self.assertEquals( dv, sha.sha(s).digest() )
            s += chr(i%256)

    def testFullDigests( self ) :
        s = ''
        fullDigests = [digest.Digest(dt) for dt in self.dtList]
        md5Digest = md5.new()
        shaDigest = sha.new()
        for i in range(1000) :
            for d in fullDigests : d.update( s )
            md5Digest.update( s )
            shaDigest.update( s )
            s += chr(i%256)
        fullDigestValues = [d.digest() for d in fullDigests]
        for (i,d) in enumerate(fullDigests) :
            self.assertEquals( len(fullDigestValues[i]), d.digestType.size() )
            if d.digestType.name() == 'MD5' :
                self.assertEquals( fullDigestValues[i], md5Digest.digest() )
            elif d.digestType.name() == 'SHA1' :
                self.assertEquals( fullDigestValues[i], shaDigest.digest() )

    def testErrors( self ) :
        self.assertRaises( digest.DigestError, digest.DigestType, 'blah' )
        self.assertRaises( TypeError, digest.Digest, None )
        d = digest.Digest( sha1Type )
        d.update( '' )
        d.digest()
        self.assertRaises( digest.DigestError, d.digest )

if __name__ == '__main__' :
    unittest.main()
