#!/usr/bin/env php
<?php

$debug = FALSE;

$locations = array(
		array(
			'name' => 'Albuquerque',
			'lat' => '35.0853',
			'lon' => '-106.6056'
		),
		array(
			'name' => 'Bend',
			'lat' => '44.2595',
			'lon' => '-121.1712'
		),
		array(
			'name' => 'Prescott',
			'lat' => '34.5400',
			'lon' => '-112.4685'
		),
		array(
			'name' => 'SantaFe',
			'lat' => '35.6870',
			'lon' => '-111.794797'
		),
		array(
			'name' => 'Sedona',
			'lat' => '34.858866',
			'lon' => '-111.794797'
		),
		array(
			'name' => 'Tucson',
			'lat' => '32.2217',
			'lon' => '-110.9265'
		)
	);


///////////////////////////
// FLUSH CURL
//
function flushCurl() {

	global $debug;

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_USERAGENT,'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36');
	curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 10);
	curl_setopt($curl, CURLOPT_FAILONERROR, false);
	curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
	curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_FRESH_CONNECT, false);
	curl_setopt($curl, CURLINFO_HEADER_OUT, true);
	curl_setopt($curl, CURLOPT_VERBOSE, false);
	curl_setopt($curl, CURLOPT_HEADER, false);

	return $curl;
}
///////////////////////////


///////////////////////////
// GET WEATHER
//
function doCURL($url) {

	global $debug;

	$curl = flushCurl();

//	print "DO CURL URL: $url\n";

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

	$outputRAW = curl_exec($curl);
//	print $outputRAW;

	$outputJSON = json_decode($outputRAW, TRUE);
//	print_r($outputJSON);

	return $outputJSON;
}
///////////////////////////


///////////////////////////
// GET WEATHER
//
function getWeather($name, $lat, $lon) {

	global $debug;

//	$station = doCURL($lat, $lon, "stations");
	$station = doCURL("https://api.weather.gov/points/". $lat .",". $lon ."/stations");

//	print_r($station);

	$stationID = $station['features'][0]['properties']['stationIdentifier'];
	$stationName = $station['features'][0]['properties']['name'];
	$timezone = $station['features'][0]['properties']['timeZone'];


//	print "stationID: $stationID\n";
//	print "stationName: $stationName\n";
//	print "timezone: $timezone\n";

	$current = doCURL("https://api.weather.gov/stations/". $stationID ."/observations/current");

	date_default_timezone_set($timezone);

	$timestamp = $current['properties']['timestamp'];

//	print $timestamp ."\n";

	$weatherArray = array(
		'epoch' => strtotime($timestamp),
		'dateTime' => date("Y-m-d H:i:s", strtotime($timestamp)),
		'temperature' => round($current['properties']['temperature']['value'] * 1.8 + 32),
		'relativeHumidity' => round($current['properties']['relativeHumidity']['value']),
		'barometricPressure' => round($current['properties']['barometricPressure']['value'] * 0.00029529983071445, 2),
		'windSpeed' => round($current['properties']['windSpeed']['value'] * 2.23694),
		'windGust' => round($current['properties']['windGust']['value'] * 2.23694),
		'windDirection' => $current['properties']['windDirection']['value'],
		'textDescription' => $current['properties']['textDescription']
		);

//	print_r($weatherArray);
//	exit();

	return $weatherArray;
}
///////////////////////////


$conditions = array();


foreach ($locations as $location) {

	$name = $location['name'];

	if ($debug) { print "NAME: $name\n"; }

	$condition = getWeather($location['name'], $location['lat'], $location['lon']);


	if ( isset($condition) ) {
		$csvString = $condition['epoch'] .",".
			$condition['dateTime'] .",".
			$condition['temperature'] .",".
			$condition['relativeHumidity'] .",".
			$condition['barometricPressure'] .",".
			$condition['windSpeed'] .",".
			$condition['windGust'] .",".
			$condition['windDirection'] .",".
			$condition['textDescription'] ."\n";

		if ($debug) { print $csvString; }

		$directory = $_SERVER['HOME'] ."/Pictures/Cams/Weather";
		$filename = date('Y', $condition['epoch']) ."-". $name .".csv";

		if ($debug) { print $directory ."/". $filename ."\n"; }

		file_put_contents($directory ."/". $filename, $csvString, FILE_APPEND);

	} else {
		print "condition empty: \"$condition\".  Skipping $name\n";
	}
}
