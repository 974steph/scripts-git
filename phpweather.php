#!/usr/bin/env php
<?php

date_default_timezone_set('UTC');
// echo date("h:i:s A");
$day = date("l");
// exit();


// West Chester
$lat = "39.967747";
$lon = "-75.572458";

// Santa Fe
// $lat = "35.6870";
// $lon = "-105.9378";

///////////////////////////
// FLUSH CURL
function flushCurl() {

	global $verbose, $fh;

	$curl = curl_init();
//	if ( file_exists($fh) ) {
		curl_setopt($curl, CURLOPT_STDERR, $fh);
//	}
	curl_setopt($curl, CURLOPT_USERAGENT,'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.13) Gecko/20080311 Firefox/2.0.0.13');
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
// POST CURL SMART
function postCurlSmart($session, $data, $url) {

	$curl = flushCurl();

	$curlHeaders = array(
		"localId: ". $session['localID_SHA']. "",
		"partnerId: ". $session['partnerID_SHA']. "",
		"date: ". $session['requestDate']. "",
		"sessionKey: ". $session['sessionKey']. "",
		"sessionSecret: ". $session['sessionSecret_SHA']. "");

	if ( is_string($data) && ! empty($data) ) {
//		file_put_contents('/tmp/dump', "IS STRING\n");
		array_push($curlHeaders, "Content-Type: application/xml");
	}

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_POST, true);
	curl_setopt($curl, CURLOPT_HTTPHEADER, $curlHeaders);

//	file_put_contents('/tmp/dump',"DATA: $data\n",FILE_APPEND);

	if ( ! empty($data) ) {
		curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
	}

	$outputRAW = curl_exec($curl);

//	file_put_contents('/tmp/dump', print_r($outputRAW),FILE_APPEND);

	$output = json_decode(json_encode(simplexml_load_string($outputRAW)), TRUE);
	$result = curl_getinfo($curl);
	curl_close($curl);

//	print_r($output);
//	print_r($result);

	if ( ! is_array($output) ) {
        	return FALSE;
	} else {
        	return array($output, $result);
	}
}
///////////////////////////



///////////////////////////
// DO ACTUAL CHECK
// function getCurl($session, $thisServer) {
function getCurl($lat, $lon) {

	$curl = flushCurl();

	$url = "http://forecast.weather.gov/MapClick.php?lat=". $lat ."&lon=". $lon ."&unit=0&lg=english&FcstType=dwml";

// 	print "URL: $url\n";

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

	$outputRAW = curl_exec($curl);

	$output = json_decode(json_encode(simplexml_load_string($outputRAW)), TRUE);

	return $output;
}
///////////////////////////

$weatherArray = getCurl($lat, $lon);

//print_r($weatherArray['data'][0]['parameters']['wordedForecast']['text']);

$city = $weatherArray['data'][0]['location']['city'];
$today = $weatherArray['data'][0]['parameters']['wordedForecast']['text'][0];
$tonight = $weatherArray['data'][0]['parameters']['wordedForecast']['text'][1];

print $day ."'s forecast for $city is ";
print strtolower($today) ."\n";
print "Tonight will be ". strtolower($tonight) ."\n";
