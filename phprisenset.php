#!/usr/bin/env php
<?php

//$doPretty = "yes";

date_default_timezone_set('America/New_York');

$now = time();

$dst=date('I', $now);
//echo "$dst\n";

/*
if ( $dst == 0 ) {
	$offset = 2;
}
else {
	$offset = 1;
}
*/

$seconds = date('Z');
$hours = floor((($seconds / 60) / 60) - $dst);

//echo "seconds: $seconds\n";
//echo "hours: $hours\n";


//Tom's Cove Park: 37.9202585, -75.3664603

$lat = '37.9202585';
$lon = '-75.3664603';

//$seconds = date('Z');
//$hours = floor(($seconds / 60) / 60);

//offical = 90 degrees 50' 90.8333 (gk: this is the "official" number to determine sunrise & sunset)
//civil = 96 degrees (gk: this is the number to obtain civilian twilight times - horizon may be visible)
//nautical = 102 degrees (gk: this is the number to obtain nautical twilight - the horizon is not visible)
//astronomical = 108 degrees (gk: this is the number for astronomical twilight - starts at sunset).
//$zenith = 108;

//$zenithRise = 90.8333;
//$zenithRise = 98;
$zenithRise = 96;
//$zenithSet = 90.8333;
$zenithSet = 96;


//$sunrise = (date_sunrise($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithRise, $hours) - (3600 * $dst));
//$sunset = (date_sunset($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithSet, $hours) - (3600 * $dst));

//$sunrise = (date_sunrise($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithRise, $hours) - (3600 * $offset));
//$sunset = (date_sunset($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithSet, $hours) - (3600 * $offset));

$sunrise = date_sunrise($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithRise, $hours);
$sunset = date_sunset($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithSet, $hours);


echo "Sunrise: ". $sunrise ."\n";
echo "Sunset: ". $sunset ."\n";

if ( isset($doPretty) ) {
	$sunrisePretty = date('Y-m-d g:i:sa', $sunrise);
	$sunsetPretty = date('Y-m-d g:i:sa', $sunset);
	echo "sunrisePretty: $sunrisePretty\n";
	echo "sunsetPretty: $sunsetPretty\n";
}
?>
