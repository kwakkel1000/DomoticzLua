commandArray = {}

currentTime = os.date("*t")
currentMinutes = currentTime.hour * 60 + currentTime.min

midDay = timeofday['SunriseInMinutes'] - timeofday['SunsetInMinutes']
midNight = timeofday['SunsetInMinutes'] - timeofday['SunriseInMinutes']
if (midDay < 0) then
    midDay = midDay + 1440
end
if (midNight < 0) then
    midNight = midNight + 1440
end

tillMidDay = timeofday['SunriseInMinutes'] - currentMinutes
tillMidNight = timeofday['SunsetInMinutes'] - currentMinutes
if (tillMidDay < 0) then
    tillMidDay = midDay + 1440
end
if (tillMidNight < 0) then
    tillMidNight = midNight + 1440
end


luxDiff = uservariables['luxLevel1'] - uservariables['luxLevel2']
if (tillMidDay < tillMidDay) then
    dayTimeMinutes = midDay - midNight
    if (dayTimeMinutes < 0) then
        dayTimeMinutes = dayTimeMinutes + 1440
    end
    calculatedWantedLux = ((tillMidDay / dayTimeMinutes) * luxDiff) + uservariables['luxLevel2'] 
else
    nightTimeMinutes = midNight - midDay
    if (nightTimeMinutes < 0) then
        nightTimeMinutes = nightTimeMinutes + 1440
    end
    calculatedWantedLux = ((tillMidDay / nightTimeMinutes) * luxDiff) + uservariables['luxLevel2'] 
end
calculatedWantedLux = math.floor(calculatedWantedLux + 0.5)
if (calculatedWantedLux ~= uservariables['wantedLux']) then
    print('wantedLux: '..tostring(calculatedWantedLux))
    commandArray['Variable:wantedLux'] = tostring(calculatedWantedLux)
end

return commandArray
