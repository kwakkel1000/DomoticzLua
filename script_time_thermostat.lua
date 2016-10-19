package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

awayTemp = "15.00"
bedroomTemp = "18.00"
normalTemp = "20.00"
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

timeDiff = os.difftime (os.time(), glib.getTime(otherdevices_lastupdate[thermostaatName]))
if (timeDiff > 1800 ) then -- only change thermostat if it hasn't changed for 30minutes
    motionDetected = false
    for key, value in pairs({'M Woonkamer', 'M Eetkamer'}) do
        if (tonumber(otherdevices_svalues[value]) > 1) then
            motionDetected = true
        end
    end
    if (motionDetected == true or otherdevices["Film"] == "On" or otherdevices["Chromecast"] == "On" or otherdevices["Game"] == "On") then
        temp = normalTemp
        print('set temp for '..thermostaatName..' to '..tostring(temp))
    elseif (wakeupStart <= minutes and wakeupEnd >= minutes) then
        temp = normalTemp
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

return commandArray
