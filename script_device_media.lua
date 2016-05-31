commandArray = {}

if (otherdevices["Film"] == "On" or otherdevices["Chromecast"] == "On") then
    if (otherdevices['S Woonkamer Media'] == 'Off') then
        commandArray['S Woonkamer Media'] = 'On'
    end
else
    timeDiff = os.difftime (os.time(), getTime(otherdevices_lastupdate["Chromecast"]))
    if (timeDiff > 300 ) then
        if (otherdevices['S Woonkamer Media'] ~= 'Off') then
            commandArray['S Woonkamer Media'] = 'Off'
        end
    end
end

return commandArray
