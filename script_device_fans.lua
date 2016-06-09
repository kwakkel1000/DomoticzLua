package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

hotOffset = 10
movieOffset = 5


currentTime = os.time()
hour = string.sub(currentTime, 12, 13)
minute = string.sub(currentTime, 15, 16)

commandArray = {}

thermostaatValue = tonumber(otherdevices_svalues['Thermostaat'])

function motion(Motion, Fan)
    motionDetected = false
    for key, value in pairs(Motion) do
        if (tonumber(otherdevices_svalues[value]) > 1) then
            motionDetected = true
        end
    end
    if (motionDetected == true) then
        for key, value in pairs(Fan) do
            glib.turnOn(value)
        end
    else
        for key, value in pairs(Fan) do
            glib.turnOff(value)
        end
    end
end

function setFan(temp, fans, motions, movie)
    if ((thermostaatValue + hotOffset) < temp) then
        for fanKey, fanValue in pairs(fans) do
            glib.turnOn(fanValue)
        end
    elseif (glib.moviePlaying() and (thermostaatValue + movieOffset) > temp) then
        for fanKey, fanValue in pairs(fans) do
            glib.turnOff(fanValue)
        end
    elseif ((not glib.moviePlaying()) and thermostaatValue < temp) then
        motion(motions, fans)
    else
        for fanKey, fanValue in pairs(fans) do
            glib.turnOff(fanValue)
        end
    end
end

-- WOONKAMER
if (devicechanged['M Woonkamer'] ~= nil or devicechanged['M Eetkamer'] ~= nil or devicechanged['TH Woonkamer'] ~= nil or devicechanged['TH Eetkamer'] ~= nil or devicechanged['Thermostaat'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
    woonkamerTemp, woonkamerHumidity, woonkamerVaag = otherdevices_svalues['TH Woonkamer']:match("([^;]+);([^;]+);([^;]+)")
    eetkamerTemp, eetkamerHumidity, eetkamerVaag = otherdevices_svalues['TH Eetkamer']:match("([^;]+);([^;]+);([^;]+)")
    temp = glib.getAverage({tonumber(woonkamerTemp), tonumber(eetkamerTemp)})
    setFan(temp, {'S Woonkamerfan'}, {'M Woonkamer', 'M Eetkamer'}, glib.moviePlaying())
end


-- SLAAPKAMER
if (devicechanged['M Slaapkamer'] ~= nil or devicechanged['TH Slaapkamer'] ~= nil or devicechanged['Thermostaat'] ~= nil) then
    slaapkamerTemp, slaapkamerHumidity, slaapkamerVaag = otherdevices_svalues['TH Slaapkamer']:match("([^;]+);([^;]+);([^;]+)")
    temp = glib.getAverage({tonumber(woonkamerTemp), tonumber(eetkamerTemp)})
    setFan(temp, {'S Slaapkamerfan'}, {'M Slaapkamer'}, false)
end

-- BADKAMER
if (not glib.timerOn(6,30 , 9,30 , tonumber(hour),tonumber(minute) ,{'S Badkamerfan'}) and not glib.timerOn(22,30 , 23,45 , hour,minute ,{'S Badkamerfan'})) then
--    if (devicechanged['M Badkamer'] ~= nil or devicechanged['TH Badkamer'] ~= nil or devicechanged['Thermostaat'] ~= nil) then
--        badkamerTemp, badkamerHumidity, badkamerVaag = otherdevices_svalues['TH Badkamer']:match("([^;]+);([^;]+);([^;]+)")
--        temp = glib.getAverage({tonumber(woonkamerTemp), tonumber(eetkamerTemp)})
--        setFan(temp, {'S Badkamerfan'}, {'M Badkamer'}, false)
--    end
    glib.turnOff('S Badkamerfan') -- temporary
end

return commandArray

