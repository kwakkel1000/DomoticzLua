package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib')

currentHour = os.date("%H")
currentMinute = os.date("%M")

sleepStartHour, sleepStartMinute = uservariables['sleepStart']:match("([^;]+):([^;]+)")
wakeupStartHour, wakeupStartMinute = uservariables['wakeupStart']:match("([^;]+):([^;]+)")
wakeupEndHour, wakeupEndMinute = uservariables['wakeupEnd']:match("([^;]+):([^;]+)")


currentMinutes = currentHour * 60 + currentMinute
sleepStart = sleepStartHour * 60 + sleepStartMinute
wakeupStart = wakeupStartHour * 60 + wakeupStartMinute
wakeupEnd = wakeupEndHour * 60 + wakeupEndMinute

-- Name of the selector for living mode
ModeSelector = 'Mode'

-- Name of the levels in the selector
ComfortLevel = 'Comfort'
HomeLevel = 'Home'
WakeupLevel = 'Wakeup'
SleepLevel = 'Sleep'
AwayLevel = 'Away'
OffLevel = 'Off' --optional

-- Values from each level name
ComfortLevelValue = '50'
HomeLevelValue = '40'
WakeupLevelValue = '30'
SleepLevelValue = '20'
AwayLevelValue = '10'
OffLevelValue = '0' --optional

commandArray = {}

if (otherdevices['Hold'] == "Off") then
    timeDiff = os.difftime (os.time(), glib.getTime(otherdevices_lastupdate['Mode']))
    if (timeDiff > 1800) then -- only change mode if it hasn't changed for 30 minutes
        motionDetected = false
        for key, value in pairs({'M Woonkamer', 'M Eetkamer'}) do
            if (tonumber(otherdevices_svalues[value]) > 1) then
                motionDetected = true
            end
        end
        if (otherdevices["Media Woonkamer"] ~= "Off" or otherdevices["Chromecast"] == "On") then
            if (otherdevices[ModeSelector] ~= ComfortLevel) then
                print("Updating '" .. ModeSelector .. "' selector to '" .. ComfortLevel .. "'")
                commandArray['UpdateDevice'] = otherdevices_idx[ModeSelector]..'|1|'..ComfortLevelValue
            end
        elseif (sleepStart <= currentMinutes or wakeupStart >= currentMinutes) then
            if (otherdevices[ModeSelector] ~= SleepLevel) then
                print("Updating '" .. ModeSelector .. "' selector to '" .. SleepLevel .. "'")
                commandArray['UpdateDevice'] = otherdevices_idx[ModeSelector]..'|1|'..SleepLevelValue
            end
        elseif (wakeupStart <= currentMinutes and wakeupEnd >= currentMinutes) then
            if (otherdevices[ModeSelector] ~= WakeupLevel) then
                print("Updating '" .. ModeSelector .. "' selector to '" .. WakeupLevel .. "'")
                commandArray['UpdateDevice'] = otherdevices_idx[ModeSelector]..'|1|'..WakeupLevelValue
            end
        elseif (motionDetected == true) then
            if (otherdevices[ModeSelector] ~= HomeLevel) then
                if (otherdevices[ModeSelector] ~= AwayLevel or tonumber(otherdevices_svalues['M Gang']) > 1) then
                    print("Updating '" .. ModeSelector .. "' selector to '" .. HomeLevel .. "'")
                    commandArray['UpdateDevice'] = otherdevices_idx[ModeSelector]..'|1|'..HomeLevelValue
                end
            end
        else
            if (otherdevices[ModeSelector] ~= AwayLevel) then
                print("Updating '" .. ModeSelector .. "' selector to '" .. AwayLevel .. "'")
                commandArray['UpdateDevice'] = otherdevices_idx[ModeSelector]..'|1|'..AwayLevelValue
            end
        end
    end
end

return commandArray
