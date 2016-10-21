package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

-- thermostat
offTemp = otherdevices_svalues['off temp']
awayTemp = otherdevices_svalues['away temp']
sleepTemp = otherdevices_svalues['sleep temp']
wakeupTemp = otherdevices_svalues['wakeup temp']
normalTemp = otherdevices_svalues['normal temp']
comfortTemp = otherdevices_svalues['comfort temp']

thermostaatName = 'Thermostaat'

-- room values
-- bedroomTemp = otherdevices_svalues['bedroom temp']

commandArray = {}

if (devicechanged['Mode'] ~= nil) then
    temp = ''
    if (otherdevices["Mode"] == "Away") then
        temp = awayTemp
    elseif (otherdevices["Mode"] == "Sleep") then
        temp = sleepTemp
    elseif (otherdevices["Mode"] == "Wakeup") then
        temp = wakeupTemp
    elseif (otherdevices["Mode"] == "Home") then
        temp = normalTemp
    elseif (otherdevices["Mode"] == "Comfort") then
        temp = comfortTemp
    -- elseif (otherdevices["Mode"] == "Off") then
    else
        temp = offTemp
    end
    thermostaatValue = otherdevices_svalues[thermostaatName]
    if (thermostaatValue ~= temp) then
        set = otherdevices_idx[thermostaatName] .. "|0|" .. temp
        commandArray['UpdateDevice'] = set
    end
end

return commandArray
