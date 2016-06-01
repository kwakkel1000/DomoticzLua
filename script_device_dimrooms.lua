package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
glib = require('glib') 

commandArray = {}

function calculateWantedDim(MeasuredLux, WantedLux, PrevDimmerLevel)
    if (MeasuredLux ~= WantedLux) then
        if (MeasuredLux < 1) then
            MeasuredLux = 1
        end
        if (PrevDimmerLevel < 5) then
            PrevDimmerLevel = 5
        end
        WantedDimLevel = math.floor(((WantedLux / MeasuredLux) * PrevDimmerLevel) + 0.5)
        if (WantedDimLevel > (uservariables['maxDimStep'] + PrevDimmerLevel)) then
            WantedDimLevel = PrevDimmerLevel + uservariables['maxDimStep']
        end
        if (WantedDimLevel > 100) then
            WantedDimLevel = 100
        end
        if (WantedDimLevel < (PrevDimmerLevel - uservariables['maxDimStep'])) then
            WantedDimLevel = PrevDimmerLevel - uservariables['maxDimStep']
        end
        if (WantedDimLevel < 10) then
            WantedDimLevel = 5
        end
        if (WantedDimLevel == PrevDimmerLevel) then
            WantedDimLevel = -1
        end
    else
        WantedDimLevel = -1
    end
    return WantedDimLevel
end

function setDimLevel(Lux, Dimmer, WantedLux)
    MeasuredLux = tonumber(otherdevices_svalues[Lux])
    timeDiff = os.difftime (glib.getTime(otherdevices_lastupdate[Lux]), glib.getTime(otherdevices_lastupdate[Dimmer]))
    if (timeDiff > 0) then
        WantedDimLevel = calculateWantedDim(MeasuredLux, WantedLux, tonumber(otherdevices_svalues[Dimmer]))
        if (WantedDimLevel ~= -1) then
            print('Dimmer: '..Dimmer..' WantedDimLevel '..tostring(WantedDimLevel))
            if (WantedDimLevel < 10) then
                if (otherdevices[Dimmer] ~= "Off") then
                    commandArray[Dimmer] = 'Off'
                    print('turn '..Dimmer..' off')
                end
            else
                if (devicechanged[Dimmer] == nil) then
                    commandArray[Dimmer] = 'Set Level '..tostring(WantedDimLevel)
                    print('set dim level for '..Dimmer..' to '..tostring(WantedDimLevel))
                end
            end
        end
    else
        if (otherdevices[Dimmer] == "Off" and MeasuredLux < WantedLux) then
            commandArray[Dimmer] = 'On'
            print('turn '..Dimmer..' on')
        end
    end
end

function motionTurnOff(Motion, Dimmer)
    if (tonumber(otherdevices_svalues[Motion]) > 1) then
        return false
    else
        if (otherdevices[Dimmer] ~= 'Off') then
            commandArray[Dimmer] = 'Off'
            print('turn '..Dimmer..' off (no motion)')
        end
        return true
    end
end

if (otherdevices["Film"] == "On" and uservariables['ChromeState'] == "PLAYING") then
    if (otherdevices['DS Woonkamer'] ~= 'Off') then
        commandArray['DS Woonkamer'] = 'Off'
    end
--    if (otherdevices['DS Woonkamer2'] ~= 'Off') then
--        commandArray['DS Woonkamer2'] = 'Off'
--    end
--    if (otherdevices['DS Woonkamer3'] ~= 'Off') then
--        commandArray['DS Woonkamer3'] = 'Off'
--    end
    if (otherdevices['DS Eetkamer'] ~= 'Off') then
        commandArray['DS Eetkamer'] = 'Off'
    end
--    setDimLevel('L Woonkamer', 'DS Woonkamer', uservariables['luxLevel3'])
    setDimLevel('L Woonkamer', 'DS Woonkamer2', uservariables['luxLevel3'])
    setDimLevel('L Woonkamer', 'DS Woonkamer3', uservariables['luxLevel3'])
--    setDimLevel('L Eetkamer', 'DS Eetkamer', uservariables['luxLevel3'])
else
    if (not motionTurnOff('M Woonkamer', 'DS Woonkamer')) then
        setDimLevel('L Woonkamer', 'DS Woonkamer', uservariables['wantedLux'])
    end
    if (not motionTurnOff('M Woonkamer', 'DS Woonkamer2')) then
        setDimLevel('L Woonkamer', 'DS Woonkamer2', uservariables['wantedLux'])
    end
    if (not motionTurnOff('M Woonkamer', 'DS Woonkamer3')) then
        setDimLevel('L Woonkamer', 'DS Woonkamer3', uservariables['wantedLux'])
    end
    if (not motionTurnOff('M Eetkamer', 'DS Eetkamer')) then
        setDimLevel('L Eetkamer', 'DS Eetkamer', uservariables['wantedLux'])
    end
end

if (not motionTurnOff('M Gang', 'DS Gang')) then
    setDimLevel('L Gang', 'DS Gang', uservariables['wantedLux'])
end
if (not motionTurnOff('M Overloop', 'DS Overloop')) then
    setDimLevel('L Overloop', 'DS Overloop', (uservariables['wantedLux'] / 2))
end
if (not motionTurnOff('M Hobby', 'DS Hobby')) then
    setDimLevel('L Hobby', 'DS Hobby', uservariables['wantedLux'])
end

return commandArray

