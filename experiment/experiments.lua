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

function Experiment:add_accelerator (address, name)
    local component = require("component")
    local proxy = component.proxy(address)
    self.devices.name = proxy
end



fusion_exp = Experiment:new{name = "fusion", info="power generation"}

local component = require("component")
fusion:add_accelerator(component.qmd_accelerator.address, "la1")

print(fusion.devices)
print(fusion.devices["la1"])
print(fusion.devices["la1"].getAcceleratorType())