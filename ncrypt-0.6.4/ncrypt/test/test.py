'''
Unified TestSuite for PyNcrypt
'''
import unittest
import ncrypt.test.testcipher
import ncrypt.test.testdigest
import ncrypt.test.testrand
import ncrypt.test.testrsa

class PyNCryptTestSuite(unittest.TestSuite):
    test_modules = [ncrypt.test.testcipher,ncrypt.test.testdigest,
        ncrypt.test.testrand,ncrypt.test.testrsa]
    def __init__(self):
        unittest.TestSuite.__init__(self)
        self.addTests(map(unittest.defaultTestLoader.loadTestsFromModule,self.test_modules))

if __name__ == '__main__':
    runner = unittest.TextTestRunner()
    runner.run(PyNCryptTestSuite())