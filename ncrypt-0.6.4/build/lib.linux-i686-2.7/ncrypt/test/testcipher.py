import sys, os, unittest
from ncrypt import cipher

class CipherTestCase( unittest.TestCase ) :
    def __init__( self, methodName='runTest' ) :
        self.algos = cipher.ALGORITHMS
        self.modes = cipher.MODES
        self.cipherTypes = []
        for a in self.algos :
            for m in self.modes :
                ct = cipher.CipherType( a, m )
                self.cipherTypes.append( ct )
        self.data = []
        k = ''
        for l in range(100) :
            self.data.append( k )
            k += chr( (l % 26) + ord('a') )
        for (i,k) in enumerate(self.data) :
            assert i == len(k)

        unittest.TestCase.__init__( self, methodName )

    def testNames( self ) :
        for ct in self.cipherTypes :
            if ct.algo() == 'DES-EDE3' and ct.mode() == 'ECB' :
                self.assertEquals( ct.algo(), ct.name() )
            else :
                self.assertEquals( '-'.join([ct.algo(),ct.mode()]), ct.name() )
        self.assertRaises( cipher.CipherError, cipher.CipherType, 'DES-EDE3', '' )
        self.assertRaises( TypeError, cipher.CipherType, 'DES-EDE3', None )
        self.assertRaises( cipher.CipherError, cipher.CipherType, 'adsfasdf', 'ECB' )

    def testCipherType( self ) :
        dtInfo = [
            (ct.name(),ct.blockSize(),ct.keyLength(),ct.ivLength())
            for ct in self.cipherTypes]

        for ct in self.cipherTypes :
            bs, ivl, keyl = ct.blockSize(), ct.ivLength(), ct.keyLength()
            self.assert_( bs >= 1 )
            self.assert_( (ivl >= 8) and (ivl <= keyl) )
            if ct.mode() in 'OFB CFB'.split() :
                self.assertEquals( 1, bs )
            else :
                self.assertEquals( bs, ivl )

    def testError1( self ) :
        self.assertRaises( TypeError, cipher.Cipher, 'DES-CBC', '12345678', None, 1 )

    def testError2( self ) :
        ct = cipher.CipherType( 'DES', 'CBC' )
        self.assertRaises( TypeError, cipher.Cipher, ct, 12345678, None, 1 )

    def testError3( self ) :
        for ct in self.cipherTypes :
            self.assertRaises( TypeError, cipher.EncryptCipher, ct, 1234, None )
            self.assertRaises( TypeError, cipher.DecryptCipher, ct, 1234, None )

            self.assertRaises( cipher.CipherError, cipher.EncryptCipher, ct, 'abcd', None )
            self.assertRaises( cipher.CipherError, cipher.DecryptCipher, ct, 'abcd', None )

    def testError4( self ) :
        for ct in self.cipherTypes :
            k = self.data[ ct.keyLength() ]
            ec = cipher.EncryptCipher( ct, k, None )
            cipherText = ec.update( 'hi' )
            cipherText += ec.finish()
            self.assertRaises( cipher.CipherError, ec.update, 'bye' )
            self.assertRaises( cipher.CipherError, ec.finish )

            dc = cipher.DecryptCipher( ct, k, None )
            plainText = dc.update( cipherText )
            plainText += dc.finish()
            self.assertRaises( cipher.CipherError, dc.update, plainText )
            self.assertRaises( cipher.CipherError, dc.finish )

    def testError5( self ) :
        for ct in self.cipherTypes :
            k = self.data[ ct.keyLength() ]
            for cipherText in self.data :
                dc = cipher.DecryptCipher( ct, k, None )
                plainText = dc.update( cipherText )
                if ct.blockSize() == 1 :
                    plainText += dc.finish()
                    self.assertEquals( len(plainText), len(cipherText) )
                else :
                    try :
                        plainText += dc.finish()
                        self.assert_( len(plainText) < len(cipherText) )
                    except cipher.CipherError :
                        pass

    def _testCipher( self, useiv ) :
        for ct in self.cipherTypes :
            k = self.data[ ct.keyLength() ]
            if useiv : iv = self.data[ ct.ivLength() ]
            else : iv = None
            for plainText in self.data :
                ec = cipher.EncryptCipher( ct, k, iv )
                cipherText = ec.update( plainText )
                cipherText += ec.finish()
                self.assert_( (len(cipherText) % ct.blockSize()) == 0 )
                if ct.blockSize() > 1 :
                    self.assert_( len(cipherText) >= ct.blockSize() )
                    self.assert_( len(cipherText)-len(plainText) <= ct.blockSize() )
                else :
                    self.assertEquals( len(cipherText),len(plainText) )
                dc = cipher.DecryptCipher( ct, k, iv )
                plainText1 = dc.update( cipherText )
                plainText1 += dc.finish()
                self.assertEquals( plainText, plainText1 )

    def testCipherWithIV( self ) :
        self._testCipher( useiv=True )
    def testCipherWithoutIV( self ) :
        self._testCipher( useiv=False )

    def _testCipherIncremental( self, useiv ) :
        allPlainText = ''.join( self.data )
        for ct in self.cipherTypes :
            k = self.data[ ct.keyLength() ]
            if useiv : iv = self.data[ct.ivLength()]
            else : iv = None

            ec = cipher.EncryptCipher( ct, k, iv )
            cipherText = []
            for x in self.data :
                cipherText.append( ec.update(x) )
            cipherText.append( ec.finish() )

            allCipherText = ''.join( cipherText )
            if ct.blockSize() > 1 :
                self.assert_( len(allCipherText) >= ct.blockSize() )
                self.assert_( len(allCipherText)-len(allPlainText) <= ct.blockSize() )
            else :
                self.assertEquals( len(allCipherText), len(allPlainText) )

            dc = cipher.DecryptCipher( ct, k, iv )
            plainText = []
            for x in cipherText :
                plainText.append( dc.update(x) )
            plainText.append( dc.finish() )

            self.assertEquals( ''.join(plainText), allPlainText )

    def testCipherIncrementalWithIV( self ) :
        self._testCipherIncremental( useiv=True )
    def testCipherIncrementalWithoutIV( self ) :
        self._testCipherIncremental( useiv=False )

    def _testCipherNoPadding( self, useiv ) :
        for ct in self.cipherTypes :
            k = self.data[ ct.keyLength() ]
            if useiv : iv = self.data[ct.ivLength()]
            else : iv = None

            cipherTextList = []
            for plainText in self.data :
                ec = cipher.EncryptCipher( ct, k, iv )
                ec.enablePadding( False )
                cipherText = ec.update( plainText )
                if len(plainText) % ct.blockSize() == 0 :
                    cipherText += ec.finish()
                    self.assertEquals( len(cipherText), len(plainText) )
                    cipherTextList.append( cipherText )
                else :
                    self.assertRaises( cipher.CipherError, ec.finish )
                    cipherTextList.append( None )

            for cipherText in cipherTextList :
                if cipherText is None : continue
                assert (len(cipherText) % ct.blockSize()) == 0
                dc = cipher.DecryptCipher( ct, k, iv )
                dc.enablePadding( False )
                plainText = dc.update( cipherText )
                plainText += dc.finish()
                self.assertEquals( plainText, self.data[len(cipherText)] )

            for cipherText in self.data :
                if len(cipherText) % ct.blockSize() != 0 : continue
                dc = cipher.DecryptCipher( ct, k, iv )
                dc.enablePadding( False )
                plainText = dc.update( cipherText )
                plainText += dc.finish()
                self.assertEquals( len(cipherText), len(plainText) )

    def testCipherNoPaddingWithIV( self ) :
        self._testCipherNoPadding( useiv=True )
    def testCipherNoPaddingWithoutIV( self ) :
        self._testCipherNoPadding( useiv=False )

if __name__ == '__main__' :
    unittest.main()
