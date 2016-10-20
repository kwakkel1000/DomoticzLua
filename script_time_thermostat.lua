package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

awayTemp = "15.00"
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
minutes = currentHour * 60 + currentMinute


commandArray = {}

if (otherdevices['Hold'] == "Off") then
    timeDiff = os.difftime (os.time(), glib.getTime(otherdevices_lastupdate[thermostaatName]))
    if (timeDiff > 1200) then -- only change thermostat if it hasn't changed for 20minutes
        motionDetected = false
        for key, value in pairs({'M Woonkamer', 'M Eetkamer'}) do
            if (tonumber(otherdevices_svalues[value]) > 1) then
                motionDetected = true
            end
        end
        if (otherdevices["Media Woonkamer"] ~= "Off" or otherdevices["Chromecast"] == "On") then
            temp = tvTemp
            print('tv, set temp for '..thermostaatName..' to '..tostring(temp))
        elseif (motionDetected == true) then
            temp = normalTemp
            print('set temp for '..thermostaatName..' to '..tostring(temp))
        elseif (wakeupStart <= minutes and wakeupEnd >= minutes) then
            temp = wakeupTemp
            print('waking up, set temp for '..thermostaatName..' to '..tostring(temp))
        else
            temp = awayTemp
            print('away, set temp for '..thermostaatName..' to '..tostring(temp))
        end
        thermostaatValue = otherdevices_svalues[thermostaatName]
        if (thermostaatValue ~= temp) then
            set = tostring(thermostaatIdx) .. "|0|" .. temp
            commandArray['UpdateDevice'] = set
            print 'actually setting the temperature'
        end
    end
end

return commandArray
