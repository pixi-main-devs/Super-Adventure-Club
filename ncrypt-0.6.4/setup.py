'''PyNCrypt: Yet another OpenSSL wrapper for python

'''

classifiers = """\
Development Status :: 3 - Alpha
Intended Audience :: Developers
License :: OSI Approved :: GNU General Public License (GPL)
Programming Language :: Python
Programming Language :: C
Topic :: Software Development :: Libraries :: Python Modules
Topic :: Security :: Cryptography
Operating System :: Microsoft :: Windows
"""
try:
    from setuptools import setup
except:
    from distutils.core import setup

from distutils.core import Extension
from distutils.command.build_ext import build_ext
from distutils.command.clean import clean
from distutils.sysconfig import get_python_inc,get_python_lib
from distutils import log
from Pyrex.Distutils import build_ext as pyrex_build_ext
import os,os.path,sys,re

class custom_clean(clean):
    def run(self):
        clean.run(self)
        log.info("removing the pyrex generated c files")
        if not self.dry_run:
            for extn in self.distribution.ext_modules:
                for srcfile in [x for x in extn.sources if x.endswith('pyx')]:
                    filename = srcfile[:-4]+'.c'
                    try:
                        os.remove(srcfile[:-4]+'.c')
                        log.info("removing '%s'", filename)
                    except OSError:
                        pass

include_dirs = []
libraries_dirs = []
libraries = []
defines = []

def scan_argv(argname,default=None):
    for arg in sys.argv:
        if len(arg) > len(argname) and arg[:len(argname)]==argname:
            sys.argv.remove(arg)
            return arg[len(argname):]
    return default

def scan_argv_dir(argname,default=None):
    ret = scan_argv(argname,default)
    if(ret != default and ret is not None):
        return re.sub(r'^(\'|\")?([\W\w]*)(?(1)(\'|\"))$',r'\2',ret)
    return ret

if sys.version_info < (2,4):
    raise RuntimeError,"PyNCrypt requires Python 2.4 or greater"

if sys.platform == "win32":
    OPENSSL_DIR = scan_argv_dir('--openssl-dir=',r'C:\openssl')
    include_dirs.append(os.path.join(OPENSSL_DIR,'include'))
    libraries_dirs.append(os.path.join(OPENSSL_DIR,'lib'))
    libraries.extend(['libeay32', 'ssleay32'])
    libraries.extend(['gdi32','user32','Ws2_32','Advapi32'])
    defines.append(('WIN32',None))
else:
    libraries.extend( ['ssl','crypto'] )

doclines = __doc__.split("\n")
include_dirs.append(get_python_inc(plat_specific=1))

setup(name='ncrypt',
      classifiers = classifiers,
      version='0.6.4',
      description='Yet another OpenSSL wrapper for python',
      author='K.S Sreeram',
      author_email='sreeram@tachyontech.net',
      maintainer='K.S Sreeram, Jeethu Rao',
      maintainer_email='sreeram@tachyontech.net, jeethu@tachyontech.net',
      url='http://www.tachyontech.net',
      packages = ['ncrypt','ncrypt.test','ncrypt.test.ssl'],
      package_dir = {'ncrypt':'ncrypt','test': 'ncrypt.test'},
      ext_modules=[Extension('_ncrypt', 
      ['ncrypt.c','utils.c',
      'ncrypt_bignum.pyx','ncrypt_cipher.pyx','ncrypt_digest.pyx',
      'ncrypt_err.pyx','ncrypt_rand.pyx','ncrypt_dh.pyx',
      'ncrypt_rsa.pyx','ncrypt_ssl.pyx','ncrypt_x509.pyx',
      # PXD Files
      #~ 'ncrypt_digest.pxd','ncrypt_rsa.pxd','ncrypt_x509.pxd'
      ],
      include_dirs=include_dirs,library_dirs=libraries_dirs,libraries=libraries,define_macros=defines)],
      cmdclass = {'build_ext': pyrex_build_ext,'clean':custom_clean}
     )
