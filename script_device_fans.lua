package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib') 

commandArray = {}

function motion(Motion, Fan)
    motionDetected = false
    for key, value in pairs(Motion) do
        if (tonumber(otherdevices_svalues[value]) > 1) then
            motionDetected = true
        end
    end
    if (motionDetected == true) then
        for key, value in pairs(Fan) do
            if (otherdevices[value] == 'Off') then
                commandArray[value] = 'On'
                print('turn '..value..' on (motion)')
            end
        end
    else
        for key, value in pairs(Fan) do
            if (otherdevices[value] ~= 'Off') then
                commandArray[value] = 'Off'
                print('turn '..value..' off (no motion)')
            end
        end
    end
end

thermostaat = tonumber(otherdevices_svalues[Thermostaat])

-- WOONKAMER
if (devicechanged['M Woonkamer'] ~= nil or devicechanged['TH Woonkamer'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
    temp, humidity, vaag = otherdevices_svalues['TH Woonkamer']:match("([^;]+);([^;]+);([^;]+)")
    if ((thermostaat + 5) < tonumber(temp)) then
        if (otherdevices['S Woonkamerfan'] == 'Off') then
            commandArray['S Woonkamerfan'] = 'On'
            print('turn '..value..' on (HOT)')
        end
    elseif (otherdevices["Film"] == "On" and otherdevices["Chromecast"] == "On" and (thermostaat + 2) > tonumber(temp)) then
        if (otherdevices['S Woonkamerfan'] ~= 'Off') then
            commandArray['S Woonkamerfan'] = 'Off'
        end
    elseif (thermostaat < tonumber(temp)) then
        motion({'M Woonkamer'}, {'S Woonkamerfan'})
    else
        if (otherdevices['S Woonkamerfan'] ~= 'Off') then
            commandArray['S Woonkamerfan'] = 'Off'
        end
    end
end


-- SLAAPKAMER
if (devicechanged['M Slaapkamer'] ~= nil or devicechanged['TH Slaapkamer'] ~= nil) then
    temp, humidity, vaag = otherdevices_svalues['TH Slaapkamer']:match("([^;]+);([^;]+);([^;]+)")
    if ((thermostaat + 5) < tonumber(temp)) then
        if (otherdevices['S Slaapkamerfan'] == 'Off') then
            commandArray['S Slaapkamerfan'] = 'On'
            print('turn '..value..' on (HOT)')
        end
    elseif (thermostaat < tonumber(temp)) then
        motion({'M Slaapkamer'}, {'S Slaapkamerfan'})
    else
        if (otherdevices['S Slaapkamerfan'] ~= 'Off') then
            commandArray['S Slaapkamerfan'] = 'Off'
        end
    end
end


-- BADKAMER
--if (devicechanged['M Badkamer'] ~= nil or devicechanged['TH Badkamer'] ~= nil) then
--    temp, humidity, vaag = otherdevices_svalues['TH Slaapkamer']:match("([^;]+);([^;]+);([^;]+)")
--    if ((thermostaat + 5) < tonumber(temp)) then
--        if (otherdevices['S Slaapkamerfan'] == 'Off') then
--            commandArray['S Slaapkamerfan'] = 'On'
--            print('turn '..value..' on (HOT)')
--        end
--    elseif (thermostaat < tonumber(temp)) then
--        motion({'M Slaapkamer'}, {'S Slaapkamerfan'})
--    else
--        if (otherdevices['S Slaapkamerfan'] ~= 'Off') then
--            commandArray['S Slaapkamerfan'] = 'Off'
--        end
--    end
--end

return commandArray

