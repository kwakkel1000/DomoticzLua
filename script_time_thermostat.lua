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

thermostaatValue = otherdevices_svalues[thermostaatName]

function setThermostat(temp, thermostat, motions, movie)
    motionDetected = false
    for key, value in pairs(motions) do
        if (tonumber(otherdevices_svalues[value]) > 1) then
            motionDetected = true
        end
    end
    if (motionDetected == true or otherdevices["Film"] == "On" or otherdevices["Chromecast"] == "On" or otherdevices["Game"] == "On") then
        if (thermostaatValue ~= temp) then
            set = tostring(thermostaatIdx) .. "|0|" .. temp
            commandArray['UpdateDevice'] = set
            print('set temp for '..thermostaatName..' to '..tostring(temp))
        end
    elseif (wakeupStart <= minutes and wakeupEnd >= minutes) then
        if (thermostaatValue ~= temp) then
            set = tostring(thermostaatIdx) .. "|0|" .. temp
            commandArray['UpdateDevice'] = set
            print('waking up, set temp for '..thermostaatName..' to '..tostring(temp))
        end
    else
        if (thermostaatValue ~= awayTemp) then
            set = tostring(thermostaatIdx) .. "|0|" .. awayTemp
            commandArray['UpdateDevice'] = set
            print('away, set temp for '..thermostaatName..' to '..tostring(awayTemp))
        end
    end
end

-- BENEDEN
-- if (devicechanged['M Woonkamer'] ~= nil or devicechanged['M Eetkamer'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
    timeDiff = os.difftime (os.time(), glib.getTime(otherdevices_lastupdate[thermostaatName]))
    if (timeDiff > 1800 ) then -- only change thermostat if it hasn't changed for 30minutes
        setThermostat(normalTemp, thermostaatIdx, {'M Woonkamer', 'M Eetkamer'}, glib.moviePlaying('Woonkamer'))
    end
-- end

-- BOVEN
-- if (devicechanged['M Woonkamer'] ~= nil or devicechanged['M Eetkamer'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
--     setThermostat(normalTemp, thermostaatIdx, {'M Woonkamer', 'M Eetkamer'}, glib.moviePlaying('Woonkamer'))
-- end

return commandArray
