package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

hotOffset = 10
movieOffset = 5
normalOffset = 2
fireTemp = 75


currentHour = os.date("%H")
currentMinute = os.date("%M")

commandArray = {}

thermostaatValue = tonumber(otherdevices_svalues['normal temp'])

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
    if (fireTemp < temp) then
        for fanKey, fanValue in pairs(fans) do
            glib.turnOff(fanValue)
        end
    elseif (otherdevices['Air'] == "On") then
        for fanKey, fanValue in pairs(fans) do
            glib.turnOn(fanValue)
        end
    elseif ((thermostaatValue + hotOffset) < temp) then
        for fanKey, fanValue in pairs(fans) do
            glib.turnOn(fanValue)
        end
    elseif (glib.moviePlaying('Woonkamer') and (thermostaatValue + movieOffset) < temp) then
        for fanKey, fanValue in pairs(fans) do
            glib.turnOn(fanValue)
        end
    elseif ((not glib.moviePlaying('Woonkamer')) and (thermostaatValue + normalOffset) < temp) then
        motion(motions, fans)
    else
        for fanKey, fanValue in pairs(fans) do
            glib.turnOff(fanValue)
        end
    end
end


if (otherdevices['Hold'] == "Off") then
    -- WOONKAMER
    if (devicechanged['M Woonkamer'] ~= nil or devicechanged['M Eetkamer'] ~= nil or devicechanged['TH Woonkamer'] ~= nil or devicechanged['TH Eetkamer'] ~= nil or devicechanged['Media Woonkamer'] ~= nil or devicechanged['Chromecast'] ~= nil or devicechanged['Air'] ~= nil) then
        woonkamerTemp, woonkamerHumidity, woonkamerVaag = otherdevices_svalues['TH Woonkamer']:match("([^;]+);([^;]+);([^;]+)")
        eetkamerTemp, eetkamerHumidity, eetkamerVaag = otherdevices_svalues['TH Eetkamer']:match("([^;]+);([^;]+);([^;]+)")
        temp = glib.getAverage({tonumber(woonkamerTemp), tonumber(eetkamerTemp)})
        setFan(temp, {'S Woonkamerfan'}, {'M Woonkamer', 'M Eetkamer'}, glib.moviePlaying('Woonkamer'))
    end
    
    
    -- SLAAPKAMER
    if (devicechanged['M Slaapkamer'] ~= nil or devicechanged['TH Slaapkamer'] ~= nil or devicechanged['Air'] ~= nil) then
        slaapkamerTemp, slaapkamerHumidity, slaapkamerVaag = otherdevices_svalues['TH Slaapkamer']:match("([^;]+);([^;]+);([^;]+)")
        temp = glib.getAverage({tonumber(slaapkamerTemp)})
        setFan(temp, {'S Slaapkamerfan'}, {'M Slaapkamer'}, false)
    end
    
    -- BADKAMER
    --if (devicechanged['M Badkamer'] ~= nil or devicechanged['TH Badkamer'] ~= nil or devicechanged['Air'] ~= nil) then
        if (otherdevices['Air'] == "On") then
            glib.turnOn('S Badkamerfan')
        elseif (not (glib.timerOn(6,30 , 9,30 , currentHour,currentMinute ,{'S Badkamerfan'}) or glib.timerOn(13,30 , 15,30 , currentHour,currentMinute ,{'S Badkamerfan'}) or glib.timerOn(23,00 , 23,59 , currentHour,currentMinute ,{'S Badkamerfan'}))) then
    --        badkamerTemp, badkamerHumidity, badkamerVaag = otherdevices_svalues['TH Badkamer']:match("([^;]+);([^;]+);([^;]+)")
    --        temp = glib.getAverage({tonumber(woonkamerTemp), tonumber(eetkamerTemp)})
    --        setFan(temp, {'S Badkamerfan'}, {'M Badkamer'}, false)
            glib.turnOff('S Badkamerfan') -- temporary
        end
    --end
end

return commandArray

