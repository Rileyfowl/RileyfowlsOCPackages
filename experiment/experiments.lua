--prints table to string
function Dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. Dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

Experiment = { 
    name = "",
    info = "",
    active = false,
    devices={},
    --key = NAME_OF_DEVICE, value = {energy = ENERGY_PERCENTAGE, port = BEAM_PORT}
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
    self.devices[name] = proxy
end

function Experiment:add_setting(name, energy_percentage, beam_port)
    self.settings[name] = {}
    self.settings[name]["energy"] = energy_percentage
    self.settings[name]["port"] = beam_port 
end

--create fusion experiment
local fusion_exp = Experiment:new{name = "fusion", info="power generation"}

--add the primary connected accelerator component
local component = require("component")
fusion_exp:add_accelerator(component.qmd_accelerator.address, "la1")

--print all connected devices
for i in next, fusion_exp.devices do 
    print(i)
end

--set only the energy percentage
fusion_exp:add_setting("la1", 50)

-- dump all settings to console
print("fusion_exp settings", Dump(fusion_exp.settings))

