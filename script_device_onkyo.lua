commandArray = {}

-- function to get information from receiver
function onkyo_status(command)
    local result = {}
    local output = io.popen ('onkyo '..command)
    for line in output:lines() do
        table.insert(result, line)
    end 
    output:close()
    return result
end
 
-- function to change settings receiver
function onkyo_change(command)
    os.execute('/usr/local/bin/onkyo '..command)
end


-- turn the receiver on/off with dummy switch 'Versterker' 
--if devicechanged['Versterker']=="On" then
--  onkyo_change('system-power:on')
--else
--  if devicechanged['Versterker']=="Off" then
--    onkyo_change('system-power:standby')
--  end
--end

-- get status information
--if devicechanged['test']=="On" then
--  status = onkyo_status('system-power:query')
--  print(status[2])
--else
--  if devicechanged['test']=="Off" then
--    status = onkyo_status('system-power:query')
--    print(status[2])
--  end
--end

-- set volume
if (devicechanged['Volume'] ~= nil) then
    if (otherdevices["Volume"] ~= "Off"
        onkyo_change('volume:'..tonumber(otherdevices_svalues['Volume']))
    else
        onkyo_change('audio-muting:on')
    end
end

return commandArray
