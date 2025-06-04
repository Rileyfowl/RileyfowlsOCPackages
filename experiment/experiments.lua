Experiment = { 
    name = "",
    info = "",
    active = false,
    devices={},
    settings = {}
}   

function Experiment:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

function Experiment:start ()
    -- do something
    self.active = true
    print("Started Experiment",self.name)
end

function Experiment:stop ()
    -- do something
    self.active = false
    print("Stopped Experiment",self.name)
end

function Experiment:add_accelerator (address):
    local component = require("component")
    local proxy = component.proxy(address)
    table.insert(self.devices, proxy)
end



strontium_exp = Experiment:new{name = "strontium"}

strontium_exp:start()
strontium_exp:stop()

strontium_exp.info = "making strontium"

print(strontium_exp.info, strontium_exp.devices)