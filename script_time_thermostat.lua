package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

awayTemp = "17.00"
bedroomTemp = "18.00"
wakeupTemp = "19.00"
normalTemp = "20.00"
tvTemp = "21.00"
wakeupStartHour = 7
wakeupStartMinute = 30
wakeupEndHour = 8
wakeupEndMinute = 30

thermostaatIdx = 205
thermostaatName = 'Thermostaat'

currentHour = os.date("%H")
currentMinute = os.date("%M")
wakeupStart = wakeupStartHour * 60 + wakeupStartMinute
wakeupEnd = wakeupEndHour * 60 + wakeupEndMinute
currentMinutes = currentHour * 60 + currentMinute


commandArray = {}

if (otherdevices['Hold'] == "Off") then
    timeDiff = os.difftime (os.time(), glib.getTime(otherdevices_lastupdate[thermostaatName]))
    if (timeDiff > 1800) then -- only change thermostat if it hasn't changed for 30 minutes
        motionDetected = false
        for key, value in pairs({'M Woonkamer', 'M Eetkamer'}) do
            if (tonumber(otherdevices_svalues[value]) > 1) then
                motionDetected = true
            end
        end
        reason = ""
        if (otherdevices["Media Woonkamer"] ~= "Off" or otherdevices["Chromecast"] == "On") then
            temp = tvTemp
            reason = 'tv, set temp for '..thermostaatName..' to '..tostring(temp)
        elseif (motionDetected == true) then
            temp = normalTemp
            reason = 'set temp for '..thermostaatName..' to '..tostring(temp)
        elseif (wakeupStart <= currentMinutes and wakeupEnd >= currentMinutes) then
            temp = wakeupTemp
            reason = 'waking up, set temp for '..thermostaatName..' to '..tostring(temp)
        else
            temp = awayTemp
            reason = 'away, set temp for '..thermostaatName..' to '..tostring(temp)
        end
        thermostaatValue = otherdevices_svalues[thermostaatName]
        if (thermostaatValue ~= temp) then
            set = tostring(thermostaatIdx) .. "|0|" .. temp
            commandArray['UpdateDevice'] = set
            print(reason)
        end
    end
end

return commandArray
