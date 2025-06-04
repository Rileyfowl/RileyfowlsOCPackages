Experiment = { 
    name = "",
    info = "",
    devices=0,
}   

function Experiment:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

function Experiment:start ()
    -- do something
    print("Started Experiment",self.name)
end

function Experiment:stop ()
    -- do something
    print("Stopped Experiment",self.name)
end

strontium_exp = Experiment:new{name = "strontium"}

strontium_exp:start()
strontium_exp:stop()

strontium_exp:info = "making strontium"

print(strontium_exp:info, strontium_exp:devices)