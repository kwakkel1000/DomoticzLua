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
    MeasuredLux = 0
    luxUpdates = {}
    luxValues = 0
    dimmers = 0
    for luxKey, luxValue in pairs(Lux) do
        luxValues = luxValues + 1
        table.insert(luxUpdates, glib.getTime(otherdevices_lastupdate[luxValue]))
        MeasuredLux = MeasuredLux + tonumber(otherdevices_svalues[luxValue])
    end
    MeasuredLux = MeasuredLux / luxValues
    for dimmerKey, dimmerValue in pairs(Dimmer) do
        dimmers = dimmers + 1
        dimmerUpdate = glib.getTime(otherdevices_lastupdate[dimmerValue])
        luxUpdated = false
        for luxKey, luxValue in pairs(luxUpdates) do
            if (os.difftime(luxValue, dimmerUpdate) > 0) then
                luxUpdated = true
            end
        end
        if (luxUpdated) then
            WantedDimLevel = calculateWantedDim(MeasuredLux, WantedLux, tonumber(otherdevices_svalues[dimmerValue]))
            if (WantedDimLevel ~= -1) then
                print('Dimmer: '..dimmerValue..' WantedDimLevel '..tostring(WantedDimLevel))
                if (WantedDimLevel < 10) then
                    if (otherdevices[dimmerValue] ~= "Off") then
                        commandArray[dimmerValue] = 'Off AFTER '..dimmers
                        print('turn '..dimmerValue..' off')
                    end
                else
                    commandArray[dimmerValue] = 'Set Level '..tostring(WantedDimLevel)..' AFTER '..dimmers
                    print('set dim level for '..dimmerValue..' to '..tostring(WantedDimLevel))
                end
            end
        else
            if (otherdevices[dimmerValue] == "Off" and MeasuredLux < WantedLux) then
                commandArray[dimmerValue] = 'On AFTER '..dimmers
                print('turn '..dimmerValue..' on')
            end
        end
    end
end

function motionTurnOff(Motion, Dimmer)
    motionDetected = false
    dimmers = 0
    for key, value in pairs(Motion) do
        if (tonumber(otherdevices_svalues[value]) > 1) then
            motionDetected = true
        end
    end
    if (motionDetected == true) then
        return false
    else
        for key, value in pairs(Dimmer) do
            dimmers = dimmers + 1
            if (otherdevices[value] ~= 'Off') then
                commandArray[value] = 'Off AFTER '..dimmers'
                print('turn '..value..' off (no motion)')
            end
        end
        return true
    end
end

-- WOONKAMER
if (devicechanged['M Woonkamer'] ~= nil or devicechanged['L Woonkamer'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
    print('film of woonkamer change')
    if (otherdevices["Film"] == "On" and otherdevices["Chromecast"] == "On") then
        if (otherdevices['DS Woonkamer'] ~= 'Off') then
            commandArray['DS Woonkamer'] = 'Off AFTER 5'
        end
--        if (otherdevices['DS Woonkamer2'] ~= 'Off') then
--            commandArray['DS Woonkamer2'] = 'Off AFTER 6'
--        end
--        if (otherdevices['DS Woonkamer3'] ~= 'Off') then
--            commandArray['DS Woonkamer3'] = 'Off AFTER 7'
--        end
        setDimLevel({'L Woonkamer'}, {'DS Woonkamer2', 'DS Woonkamer3'}, uservariables['luxLevel3'])
    else
        if (not motionTurnOff({'M Woonkamer'}, {'DS Woonkamer', 'DS Woonkamer2', 'DS Woonkamer3'})) then
            setDimLevel({'L Woonkamer'}, {'DS Woonkamer', 'DS Woonkamer2', 'DS Woonkamer3'}, uservariables['wantedLux'])
        end
    end
end

-- EETKAMER
if (devicechanged['M Eetkamer'] ~= nil or devicechanged['L Eetkamer'] ~= nil or devicechanged['Film'] ~= nil or devicechanged['Chromecast'] ~= nil) then
    print('film of eetkamer change')
    if (otherdevices["Film"] == "On" and otherdevices["Chromecast"] == "On") then
        if (otherdevices['DS Eetkamer'] ~= 'Off') then
            commandArray['DS Eetkamer'] = 'Off AFTER 5'
        end
        if (otherdevices['DS Bijkeuken'] ~= 'Off') then
            commandArray['DS Bijkeuken'] = 'Off AFTER 6'
        end
--        setDimLevel({'L Eetkamer'}, {'DS Eetkamer', 'DS Bijkeuken'}, uservariables['wantedLux3'])
    else
        if (not motionTurnOff({'M Eetkamer'}, {'DS Eetkamer', 'DS Bijkeuken'})) then
            setDimLevel({'L Eetkamer'}, {'DS Eetkamer', 'DS Bijkeuken'}, uservariables['wantedLux'])
        end
    end
end

-- GANG
if (devicechanged['M Gang'] ~= nil or devicechanged['L Gang'] ~= nil) then
--    print('gang change')
    if (not motionTurnOff({'M Gang'}, {'DS Gang'})) then
        setDimLevel({'L Gang'}, {'DS Gang'}, uservariables['wantedLux'])
    end
end

-- OVERLOOP
if (devicechanged['M Overloop'] ~= nil or devicechanged['L Overloop'] ~= nil) then
--    print('overloop change')
    if (not motionTurnOff({'M Overloop'}, {'DS Overloop'})) then
        setDimLevel({'L Overloop'}, {'DS Overloop'}, (uservariables['wantedLux'] / 2))
    end
end

-- HOBBY
if (devicechanged['M Hobby'] ~= nil or devicechanged['L Hobby'] ~= nil) then
--    print('hobby change')
    if (not motionTurnOff({'M Hobby'}, {'DS Hobby'})) then
        setDimLevel({'L Hobby'}, {'DS Hobby'}, uservariables['wantedLux'])
    end
end

-- SLAAPKAMER
if (devicechanged['M Slaapkamer'] ~= nil or devicechanged['L Slaapkamer'] ~= nil) then
--    print('slaapkamer change')
    if (not motionTurnOff({'M Slaapkamer'}, {'DS Slaapkamer'})) then
        setDimLevel({'L Slaapkamer'}, {'DS Slaapkamer'}, uservariables['wantedLux'])
    end
end


-- ACHTERTUIN
if (timeofday['Nighttime']) then
    print('its nighttime')
    setDimLevel({'L Eetkamer'}, {'DS Achtertuin'}, uservariables['wantedLux']) -- L Eetkamer should change
else
    if (otherdevices['DS Achtertuin'] ~= 'Off') then
        commandArray['DS Achtertuin'] = 'Off'
    end
end

return commandArray

