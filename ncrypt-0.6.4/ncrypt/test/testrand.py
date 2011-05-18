import sys, os, unittest
from ncrypt import rand

class RandTestCase( unittest.TestCase ) :
    def testBytes( self ) :
        for i in range(1,2000) :
            s = rand.bytes( i, checkResult=1 )
            self.assertEquals( len(s), i )

    def testLargeBytes( self ) :
        n = 4096
        for i in range(2000) :
            s = rand.bytes( n, checkResult=1 )
            self.assertEquals( len(s), n )

    def testPseudoBytes( self ) :
        for i in range(1,2000) :
            s = rand.pseudoBytes( i )
            self.assertEquals( len(s), i )

    def testLargePseudoBytes( self ) :
        n = 4096
        for i in range(2000) :
            s = rand.pseudoBytes( n )
            self.assertEquals( len(s), n )

if __name__ == '__main__' :
    unittest.main()
