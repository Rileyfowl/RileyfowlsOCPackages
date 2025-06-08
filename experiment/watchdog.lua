local thread = require("thread")

local component = require("component")

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

local devices = {}
for address, name in component.list("qmd_accelerator", true) do
  table.insert(devices, component.proxy(address))
end

local t = thread.create(function(devices)
  while true do
    for proxy in next, devices do
        if proxy.isAcceleratorOn() then
            local heatInfo = proxy.getHeatBufferInfo()
            if heatInfo["stored_heat"] > 0.25*heatInfo["heat_capacity"] then
                proxy.setComputerControlled(true)
                proxy.setEnergyPercentage(0)
                print("Emergency shutdown of", Dump(proxy.getOutputParticleInfo()))
            end
        end
    end
    os.sleep()
  end
end, devices)
