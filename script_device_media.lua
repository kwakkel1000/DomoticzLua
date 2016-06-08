package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

commandArray = {}

if (otherdevices["Film"] == "On" or otherdevices["Chromecast"] == "On") then
    glib.turnOn('S Woonkamer Media')
else
    timeDiff = os.difftime (os.time(), glib.getTime(otherdevices_lastupdate["Chromecast"]))
    if (timeDiff > 300 ) then
        glib.turnOff('S Woonkamer Media')
    end
end

return commandArray
