Account = { balance=0,
            withdraw = function (self, v)
                             self.balance = self.balance - v
                           end
        }   
    
function Account:deposit (v)
    self.balance = self.balance + v
end
    
function Account:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

a = Account:new{balance = 1000}
a:withdraw(100.00)

b = Account:new()
b:deposit(300)

print(a.balance)
print(b.balance)
