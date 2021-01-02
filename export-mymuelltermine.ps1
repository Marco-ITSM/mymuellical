#enter city name
$city = "Langenfeld"
#enter street name
$street = "Hauptstraﬂe"

function export-ical {
    param (
        $dates,
        $filepath
    )
    $i = 0
    $begin = @"
BEGIN:VCALENDAR
VERSION:2.0
PRODID:MarcoHahnen
BEGIN:VTIMEZONE
TZID:CET
BEGIN:DAYLIGHT
TZOFFSETFROM:+0100
TZOFFSETTO:+0200
TZNAME:Central European Summer Time
DTSTART:20160327T020000
RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=3
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:+0200
TZOFFSETTO:+0100
TZNAME:Central European Time
DTSTART:20161030T030000
RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
END:STANDARD
END:VTIMEZONE

"@
    foreach($date in $dates)
    {
        $dtstart = $($date.date).Tostring("yyyyMMdd")
        $dtend = $($date.date).AddDays(1).tostring("yyyyMMdd")
        $proc = @"
BEGIN:VEVENT
UID:$i
SUMMARY:$($date.garbage_type)
CLASS:PUBLIC
DTSTART;VALUE=DATE:$dtstart
DTEND;VALUE=DATE:$dtend
END:VEVENT

"@
        $proclist += $proc
        $i++
    }

    $end = "END:VCALENDAR"
    $ics = $begin + $proclist + $end
    $ics | Out-File -FilePath $filepath
}

$citiesurl = "https://mymuell.jumomind.com/mmapp/alexa/app_api.php?r=cities"
$cities = (Invoke-WebRequest -Uri $citiesurl).content | ConvertFrom-Json
$city = $cities | Where-Object name -eq $city

$streetsurl = "https://mymuell.jumomind.com/mmapp/alexa/app_api.php?r=streets&city_id=" + $($city.id) + "&dbIdentifier=" + $($city.dbIdentifier)
$streets = (Invoke-WebRequest -Uri $streetsurl).content | ConvertFrom-Json
$street = $streets | Where-Object name -eq $street

$namesurl = "https://mymuell.jumomind.com/mmapp/api.php?r=trash&city_id=" + $($city.id) + "&area_id=" + $($street.area_id) + "&ws=3"
$names = (Invoke-WebRequest -Uri $namesurl).content | ConvertFrom-Json

$termineurl = "https://mymuell.jumomind.com/webservice.php?idx=termins&city_id=" + $($city.id) + "&area_id=" + $($street.area_id)
$termine = (Invoke-WebRequest -Uri $termineurl).content | ConvertFrom-Json 

$list = @()
foreach($termin in $termine._data)
{
    $listentry = [PSCustomObject]@{
        date = [datetime]::ParseExact($termin.cal_date_normal,'dd.MM.yyyy',$null)
        garbage_type = ($names | Where-Object { $_.name -eq $($termin.cal_garbage_type)}).title
    }
    $list += $listentry
}

export-ical -dates $list -filepath "muelltermine-$($city.id)-$($street.area_id).ics"