#
# Python has no implementation for handling constants so I've
# tried to put in something similiar here. Python guru's be damned! 
# No sane language should be without a constant!
#
class _const:
    class ConstError(TypeError): pass
    # We can set an attribute just ONCE
    def __setattr__(self,name,value):
        if self.__dict__.has_key(name):
            # if we try set it a second time, throw a fit of panick 
            raise self.ConstError, "Can't rebind const(%s)"%name
        self.__dict__[name]=value
    # We don't actually delete an attribute here, just set it to ''
    def __delattr__(selfself, name):
        if self.__dict__.has_key(name):
            self.__dict__[name]=''
        else:
            # if attribute was not previously given a value, throw a
            # wobbler
            raise self.ConstError, "Attribute was not previously assigned a value (%s)"%name
# Usage           :
#   import const
#       and bind an attribute ONCE:
#       const.magic = 23
#       but NOT re-bind it:
#       const.magic = 88   will raises const.ConstError

