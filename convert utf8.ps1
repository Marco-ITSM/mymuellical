$icsnew = "C:\Users\HahnenMarco\OneDrive - Marco Hahnen\ps\mymuellical\ics"
$icsold = "C:\Users\HahnenMarco\OneDrive - Marco Hahnen\ps\mymuellical\ics-old"

cd $icsold
foreach( $i in get-childitem -recurse -name  ) {
    get-content $i | out-file -encoding utf8 -filepath $icsnew/$i
    $i
}