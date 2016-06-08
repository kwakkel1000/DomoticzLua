local glib = {};

function glib.getTime(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   return os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
end

function glib.round(val, decimal)
    if (decimal) then
        return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val+0.5)
    end
end


function glib.getAverage(values)
    amount = 0
    tmpValue = 0
    for key, value in pairs(values) do
        amount = amount + 1
        tmpValue = tmpValue + value
    end
    tmpValue = tmpValue / amount
    print('average value: '..tostring(tmpValue))
    return tmpValue
end

function glib.moviePlaying()
    playing = false
    if (otherdevices["Film"] == "On" and otherdevices["Chromecast"] == "On") then
        playing = true
    end
    return playing
end

function glib.turnOn(device)
    if (otherdevices[device] == 'Off') then
        commandArray[device] = 'On'
        print('turn on: '..device)
    end
end

function glib.turnOff(device)
    if (otherdevices[device] ~= 'Off') then
        commandArray[device] = 'Off'
        print('turn off: '..device)
    end
end

function glib.setLevel(device, level)
    if (level < 10) then
        glib.turnOff(device)
    else
        commandArray[device] = 'Set Level '..tostring(level)
        print('set dim level for '..device..' to '..tostring(level))
    end
end

return glib
