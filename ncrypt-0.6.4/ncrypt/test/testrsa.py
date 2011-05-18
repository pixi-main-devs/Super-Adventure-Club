import sys, os, unittest
from ncrypt import rsa, digest

class RSATestCase( unittest.TestCase ) :
    def __init__( self, methodName='runTest' ) :
        self.keys = {}
        self.data = []
        x = ''
        for l in range(256) :
            self.data.append( x )
            x += chr( (l % 26) + ord('a') )
        for (i,x) in enumerate(self.data) :
            assert i == len(x)

        unittest.TestCase.__init__( self, methodName )

    def _genKey( self, numBits ) :
        k = rsa.RSAKey()
        k.generate( numBits )
        self.assertEquals( k.size()*8, numBits )
        self.assert_( k.hasPrivateKey )
        return k

    def _getKey( self, numBits ) :
        if not self.keys.has_key(numBits) :
            self.keys[numBits] = self._genKey( numBits )
        return self.keys[numBits]

    def _testEncrypt( self, pk, sk ) :
        print ''
        for paddingMode in [rsa.PADDING_PKCS1,rsa.PADDING_PKCS1_OAEP] :
            for plainText in self.data :
                if len(plainText) > pk.maxInputSize(paddingMode) :
                    self.assertRaises( rsa.RSAError, pk.encrypt,
                            plainText, paddingMode )
                else :
                    print 'pad=%d, max=%d, len(pt)=%d' % (
                            pk.paddingSize(paddingMode),
                            pk.maxInputSize(paddingMode),
                            len(plainText) )
                    cipherText = pk.encrypt( plainText, paddingMode )
                    self.assertEquals( len(cipherText), pk.size() )
                    plainText1 = sk.decrypt( cipherText, paddingMode )
                    self.assertEquals( plainText1, plainText )

    def _testSign( self, pk, sk ) :
        print ''
        for algo in digest.ALGORITHMS :
            print algo
            dt = digest.DigestType( algo )
            hashList = []
            sigList = []
            print 'signing...'
            for msg in self.data :
                d = digest.Digest(dt).digest( msg )
                hashList.append( d )
                sig = sk.sign( d, dt )
                sigList.append( sig )
            print 'verifying...'
            for (hash,sig) in zip(hashList,sigList) :
                pk.verify( sig, hash, dt )
            hashList = hashList[1:] + hashList[:1]
            for (hash,sig) in zip(hashList,sigList) :
                self.assertRaises( rsa.RSAError, pk.verify, sig, hash, dt )

    def _splitKey( self, k ) :
        pkData, skData = k.getPublicKey(), k.getPrivateKey()
        pk, sk = rsa.RSAKey(), rsa.RSAKey()
        pk.loadPublicKey( pkData )
        sk.loadPrivateKey( skData )
        return (pk, sk)

    def _testKeyEncrypt( self, numBits, split=False, blinding=False ) :
        k = self._getKey( numBits )
        if split :
            pk, sk = self._splitKey( k )
        else :
            pk, sk = k, k
        sk.enableBlinding( blinding )
        self._testEncrypt( pk, sk )

    def _testKeySign( self, numBits, split=False, blinding=False ) :
        k = self._getKey( numBits )
        if split :
            pk, sk = self._splitKey( k )
        else :
            pk, sk = k, k
        sk.enableBlinding( blinding )
        self._testSign( pk, sk )

    def testDefault( self ) :
        self._testKeyEncrypt( 1024 )
        self._testKeySign( 1024 )

    def testBlinding( self ) :
        self._testKeyEncrypt( 1024, blinding=True )
        self._testKeySign( 1024, blinding=True )

    def testSplit( self ) :
        self._testKeyEncrypt( 1024, split=True )
        self._testKeySign( 1024, split=True )

    def testSplitBlinding( self ) :
        self._testKeyEncrypt( 1024, split=True, blinding=True )
        self._testKeySign( 1024, split=True, blinding=True )

    def test_PEM_encryption( self ) :
        key = self._getKey( 1024 )
        data = key.toPEM_PrivateKey( password='foo' )
        data1 = key.toPEM_PrivateKey( password='bar' )
        data2 = key.toPEM_PrivateKey()
        new_key = rsa.RSAKey()
        self.assertRaises( rsa.RSAError, lambda:new_key.fromPEM_PrivateKey(data) )
        self.assertRaises( rsa.RSAError, lambda:new_key.fromPEM_PrivateKey(data,password='bar') )
        new_key.fromPEM_PrivateKey( data, password='foo' )
        self.failIfEqual( data, data1 )
        self.failIfEqual( data, data2 )
        data = key.toPEM_PrivateKey( password='foo\x00bar\x00' )
        k = rsa.RSAKey()
        k.fromPEM_PrivateKey( data, password='foo\x00bar\x00' )
        self.assertEqual( k.toPEM_PrivateKey(), key.toPEM_PrivateKey() )

if __name__ == '__main__' :
    unittest.main()
