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
    local found = false
    for address, componentType in component.list("qmd_accelerator", true) do
        local proxy = component.proxy(address)
        if proxy.isBeamPort(x,y,z) and proxy.isComplete() then
            self.devices[name] = proxy
            found = true
            break
        end
    end
    if not found then
        print("WARNING: Could not find accelerator", name, "at", x, y, z)
    end
end

function Experiment:addSetting(name, energy_percentage, beam_port)
    if self.devices[name] then
        self.settings[name] = {}
        self.settings[name]["energy"] = energy_percentage
        self.settings[name]["port"] = beam_port 
    else
        print("WARNING:", name, "not in devices. No Settings added.")
    end
end


--create fusion experiment
local glueballs = Experiment:new{name = "glueballs", info="Glueball generation"}

--add the linear accel to get protons up to 5 MeV
glueballs:addAcceleratorByPort(526, 61,382, "Input LA")
glueballs:addSetting("Input LA", 100)

--add the synchroton to get protons up energy for spallation
glueballs:addAcceleratorByPort(534, 61,382, "Spallation Sync")
glueballs:addSetting("Spallation Sync", 5)

--add the main proton synchroton 
glueballs:addAcceleratorByPort(558, 72,336, "Proton Sync")
glueballs:addSetting("Proton Sync", 100)

--add the main antiproton synchroton
glueballs:addAcceleratorByPort(534, 72,336, "Antiproton Sync")
glueballs:addSetting("Antiproton Sync", 100)

-- dump all settings to console
print("glueballs settings", Dump(glueballs.settings))

--[[
local component = require("component")
local sides = require("sides")
local redstoneio = component.proxy(component.list("redstone")())

while true do
    if redstoneio.getInput(sides.top)>0 and not glueballs.active then
        glueballs:start()
    elseif redstoneio.getInput(sides.top)==0 and glueballs.active then
        glueballs:stop()
        break
    end
end
--]]

local event = require("event")

while true do
  local id, address, side, oldValue, newValue = event.pullMultiple("interrupted", "redstone_changed")
  if id == "interrupted" then
    print("soft interrupt, closing")
    break
  elseif id=="redstone_changed" then
    if oldValue==0 and newValue>0 then
        if not glueballs.active then
            glueballs:start()
        end
    elseif oldValue>0 and newValue==0 then 
         if glueballs.active then
            glueballs:stop()
        end
    end
  end
end