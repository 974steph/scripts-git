#!/usr/bin/php
<?php

$doPretty = "yes";

$debug = false;

$cmdOptions = getopt("a:o:t:");

if ( $debug ) { var_dump($cmdOptions); }

foreach ( $cmdOptions as $cmdOption => $cmdValue) {
	if ( $cmdOption == "a" ) { $lat = "$cmdValue"; }
	if ( $cmdOption == "o" ) { $lon = "$cmdValue"; }
	if ( $cmdOption == "t" ) { $thisTZ = "$cmdValue"; }
}

// if ( isset($debug) ) {
if ( $debug ) {
	if ( isset($lat) ) { echo "lat: $lat\n"; }
	if ( isset($lon) ) { echo "lon: $lon\n"; }
	if ( isset($thisTZ) ) { echo "thisTZ: $thisTZ\n"; }
}


if ( ! isset($lat) ) { $lat = '37.9202585';}
if ( ! isset($lon) ) { $lon = '-75.3664603';}

if ( ! isset($thisTZ) ) {
	$thisTZ = 'America/New_York';
} else {
	if ( $debug ) { echo "argument: $thisTZ\n"; }
}


date_default_timezone_set($thisTZ);

$now = time($thisTZ);

$dst = date('I', $now);

$seconds = date('Z');
$hours = floor((($seconds / 60) / 60) - $dst);

//echo "seconds: $seconds\n";
if ( $debug ) { echo "hours: $hours\n"; }


//Tom's Cove Park: 37.9202585, -75.3664603

/*
	http://api.timezonedb.com/?lat=44.056434&lng=-121.308085&key=AYQ22XS8KBMX
*/



$dateTimeZoneUTC = new DateTimeZone("UTC");
$dateTimeUTC = new DateTime("now", $dateTimeZoneUTC);
$dateOff = (date('O',$now) + $dst);

// if ( isset($debug) ) {
if ( $debug ) {
	echo "dateTimeUTC: ";
	print_r($dateTimeUTC);
//	echo "something: $something\n";

	echo "dateOff: $dateOff\n";
}


//offical = 90 degrees 50' 90.8333 (gk: this is the "official" number to determine sunrise & sunset)
//civil = 96 degrees (gk: this is the number to obtain civilian twilight times - horizon may be visible)
//nautical = 102 degrees (gk: this is the number to obtain nautical twilight - the horizon is not visible)
//astronomical = 108 degrees (gk: this is the number for astronomical twilight - starts at sunset).
//$zenith = 108;

// Higher is sooner sunrise
//$zenithRise = 96;
$zenithRise = 102;

// Higher is later sunset
//$zenithSet = 96;
$zenithSet = 102;


$sunrise = date_sunrise($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithRise, $hours);
$sunset = date_sunset($now, SUNFUNCS_RET_TIMESTAMP, $lat, $lon, $zenithSet, $hours);

echo "Sunrise: ". $sunrise ."\n";
echo "Sunset: ". $sunset ."\n";

if ( isset($doPretty) ) {
	$nowPretty = date('Y-m-d g:i:sa', $now);
	$sunrisePretty = date('Y-m-d g:i:sa', $sunrise);
	$sunsetPretty = date('Y-m-d g:i:sa', $sunset);
	echo "now: $now\n";
	echo "nowPretty: $nowPretty\n";
	echo "sunrisePretty: $sunrisePretty\n";
	echo "sunsetPretty: $sunsetPretty\n";
}
?>
