package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

awayTemp = "15.0"
bedroomTemp = "18.0"
normalTemp = "20.0"

currentHour = os.date("%H")
currentMinute = os.date("%M")

commandArray = {}

thermostaatValue = tonumber(otherdevices_svalues['Thermostaat'])

function setThermostat(temp, thermostats, motions, movie)
    motionDetected = false
    for key, value in pairs(motions) do
        if (tonumber(otherdevices_svalues[value]) > 1) then
            motionDetected = true
        end
    end
    if (motionDetected == true or otherdevices["Film"] == "On" or otherdevices["Chromecast"] == "On" or otherdevices["Game"] == "On") then
        for key, value in pairs(thermostats) do
            commandArray[value] = 'Set Level '..temp
            print('set temperature for '..value..' to '..temp)
        end
    else
        for key, value in pairs(thermostats) do
            commandArray[value] = 'Set Level '..temp
            print('set temperature for '..value..' to '..awayTemp)
        end
    end
end

-- BENEDEN
if (devicechanged['M Woonkamer'] ~= nil or devicechanged['M Eetkamer'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
    setThermostat(normalTemp, {'Thermostat'}, {'M Woonkamer', 'M Eetkamer'}, glib.moviePlaying('Woonkamer'))
end

-- BOVEN
-- if (devicechanged['M Woonkamer'] ~= nil or devicechanged['M Eetkamer'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
--     setThermostat(normalTemp, {'Thermostat'}, {'M Woonkamer', 'M Eetkamer'}, glib.moviePlaying('Woonkamer'))
-- end

return commandArray
