import xmlrpclib

class MyFuncs:
    def div(self, x, y) : return x // y


s = xmlrpclib.ServerProxy('https://localhost:8000')
print s.pow(2,3)  # Returns 2**3 = 8
print s.add(2,3)  # Returns 5
print s.div(5,2)  # Returns 5//2 = 2
print s.getpubkey("232:232:")

# Print list of available methods
print s.system.listMethods()
