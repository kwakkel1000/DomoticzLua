commandArray = {}

currentTime = os.date("*t")
currentMinutes = currentTime.hour * 60 + currentTime.min

midDay = timeofday['SunsetInMinutes'] - timeofday['SunriseInMinutes']
if (midDay < 0) then
    midDay = midDay + 1440
end
midNight = timeofday['SunriseInMinutes'] - timeofday['SunsetInMinutes']
if (midNight < 0) then
    midNight = midNight + 1440
end

tillMidDay = midDay - currentMinutes
if (tillMidDay < 0) then
    tillMidDay = midDay + 1440
end
tillMidNight = midNight - currentMinutes
if (tillMidNight < 0) then
    tillMidNight = midNight + 1440
end

print('midDay/midNight: '..tostring(midDay)..'/'..tostring(midNight))
print('till midDay/midNight: '..tostring(tillMidDay)..'/'..tostring(tillMidNight))

luxDiff = uservariables['luxLevel1'] - uservariables['luxLevel2']
if (tillMidDay < tillMidDay) then
    dayTimeMinutes = timeofday['SunsetInMinutes'] - timeofday['SunriseInMinutes']
    if (dayTimeMinutes < 0) then
        dayTimeMinutes = dayTimeMinutes + 1440
    end
    print('its closer to midday, dayLength: '..tostring(dayTimeMinutes))
    calculatedWantedLux = ((tillMidDay / dayTimeMinutes) * luxDiff) + uservariables['luxLevel2'] 
else
    nightTimeMinutes = timeofday['SunriseInMinutes'] - timeofday['SunsetInMinutes']
    if (nightTimeMinutes < 0) then
        nightTimeMinutes = nightTimeMinutes + 1440
    end
    print('its closer to midnight, nightLength: '..tostring(nightTimeMinutes))
    calculatedWantedLux = ((tillMidDay / nightTimeMinutes) * luxDiff) + uservariables['luxLevel2'] 
end
calculatedWantedLux = math.floor(calculatedWantedLux + 0.5)
if (calculatedWantedLux ~= uservariables['wantedLux']) then
    print('wantedLux: '..tostring(calculatedWantedLux))
    commandArray['Variable:wantedLux'] = tostring(calculatedWantedLux)
end

return commandArray
