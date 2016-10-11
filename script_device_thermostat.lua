package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

awayTemp = 15
bedroomTemp = 18
normalTemp = 20

currentHour = os.date("%H")
currentMinute = os.date("%M")

commandArray = {}

thermostaatValue = tonumber(otherdevices_svalues['Thermostaat'])

function motion(Motion, Thermostat, Temp)
    motionDetected = false
    for key, value in pairs(Motion) do
        if (tonumber(otherdevices_svalues[value]) > 1) then
            motionDetected = true
        end
    end
    if (motionDetected == true) then
        for key, value in pairs(Thermostat) do
            glib.setLevel(value, Temp)
        end
    else
        for key, value in pairs(Thermostat) do
            glib.setLevel(value, awayTemp)
        end
    end
end

function setThermostat(temp, thermostats, motions, movie)
    if (glib.moviePlaying('Woonkamer')) then
        for thermostatKey, thermostatValue in pairs(thermostats) do
            glib.turnOn(thermostatValue)
        end
    elseif (not glib.moviePlaying('Woonkamer')) then
        motion(motions, thermostats)
    else
        for thermostatKey, thermostatValue in pairs(thermostats) do
            glib.setLevel(thermostatValue, awayTemp)
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
