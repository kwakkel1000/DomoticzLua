commandArray = {}

currentTime = os.date("*t")
currentMinutes = currentTime.hour * 60 + currentTime.min
tillSunset = timeofday['SunsetInMinutes'] - currentMinutes
if (tillSunset < 0) then
    tillSunset = tillSunset + 1440
end
tillSunrise = timeofday['SunriseInMinutes'] - currentMinutes
if (tillSunrise < 0) then
    tillSunrise = tillSunrise + 1440
end
luxDiff = uservariables['luxLevel1'] - uservariables['luxLevel2']
if (tillSunset < tillSunrise) then
    dayTimeMinutes = timeofday['SunriseInMinutes'] - timeofday['SunsetInMinutes']
    if (dayTimeMinutes < 0) then
        dayTimeMinutes = dayTimeMinutes + 1440
    end
    calculatedWantedLux = ((tillSunset / dayTimeMinutes) * luxDiff) + uservariables['luxLevel2'] 
else
    nightTimeMinutes = timeofday['SunsetInMinutes'] - timeofday['SunriseInMinutes']
    if (nightTimeMinutes < 0) then
        nightTimeMinutes = nightTimeMinutes + 1440
    end
    calculatedWantedLux = ((tillSunrise / nightTimeMinutes) * luxDiff) + uservariables['luxLevel2'] 
end
calculatedWantedLux = math.floor(calculatedWantedLux + 0.5)
if (calculatedWantedLux ~= uservariables['wantedLux']) then
    commandArray['Variable:wantedLux'] = tostring(calculatedWantedLux)
end

return commandArray
