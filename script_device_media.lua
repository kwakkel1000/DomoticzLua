commandArray = {}

function getTime(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   return os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
end

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
