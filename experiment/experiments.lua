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
    for name, setting in pairs(self.settings) do
        local accel_proxy = self.devices[name]
        accel_proxy.setComputerControlled(true)
        accel_proxy.setEnergyPercentage(setting["energy"])
    end 
    self.active = true
    print("Started Experiment",self.name)
end

function Experiment:stop ()
    for name, accel_proxy in pairs(self.devices) do
        accel_proxy.setEnergyPercentage(0)
        accel_proxy.setComputerControlled(false)
    end 
    self.active = false
    print("Stopped Experiment",self.name)
end

function Experiment:addAccelerator (address, name)
    local component = require("component")
    local proxy = component.proxy(address)
    self.devices[name] = proxy
end

function Experiment:addAcceleratorByPort(x,y,z, name)
    local component = require("component")
    for address, componentType in component.list("qmd_accelerator", true) do
        local proxy = component.proxy(address)
        if proxy.isBeamPort(x,y,z) then
            self.devices[name] = proxy
            break
        end
    end
end

function Experiment:addSetting(name, energy_percentage, beam_port)
    self.settings[name] = {}
    self.settings[name]["energy"] = energy_percentage
    self.settings[name]["port"] = beam_port 
end

--create fusion experiment
local glueballs = Experiment:new{name = "glueballs", info="Glueball generation"}

--add the linear accel to get protons up to 5 MeV
glueballs:addAcceleratorByPort(526, 61,382, "Input LA")
glueballs:addSetting("Input LA", 100)

--add the synchroton to get protons up energy for spallation
glueballs:addAcceleratorByPort(534, 61,382, "Spallation Sync")
glueballs:addSetting("Spallation Sync", 5)

--print all connected devices
for i in next, glueballs.devices do 
    print(i)
end

-- dump all settings to console
print("glueballs settings", Dump(glueballs.settings))

