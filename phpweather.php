#!/usr/bin/env php
<?php

include $_SERVER['HOME'] ."/Sources/scripts-git/secret_stuff.php";

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
//
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
// GET WEATHER
//
function getWeather($lat, $lon) {

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


///////////////////////////
// GET QUOTE
//
function getQuote() {

	$curl = flushCurl();

	$url = "http://www.motivationalquotes101.com";

//	print "URL: ". $url ."\n";

//	curl -s http://www.motivationalquotes101.com/ | grep 'id="quote"' | sed 's/</\n</g' | egrep "^<strong>|href.*quotes" | tail -n2 | sed 's/<[^>]\+>//g'

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

	$outputRAW = curl_exec($curl);
//	print "outputRAW: ". $outputRAW."\n";
//	print_r($outputRAW);
//	exit();

//	$output = json_decode(json_encode(simplexml_load_string($outputRAW)), TRUE);

	$dom = new DOMDocument;
	$dom->loadHTML($outputRAW);

/*
	$array = array();
	foreach($dom as $node){
		$array[] = $node;
	}

	print_r($array);
	exit();
*/

//	print "STRONG\n";

	foreach($dom->getElementsByTagName('strong') as $node) {

//		print_r($node);

		if ($node->textContent) {
//			print "textContent: ". $node->textContent ."\n";
			$output[] = $node->textContent;
		}
	}

//	print "HREF\n";

	foreach($dom->getElementsByTagName('a') as $node) {

		if ( strlen($node->textContent) > 0) {
//		if ($node->attributes->name == "href") {
//			print_r($node);
//			print "textContent: ". $node->textContent ."\n";


			$textContent = $node->textContent;


			foreach ($node->attributes as $n) {
//				print_r($n);

//				$name = $n->name;
//				print "NAME2: \"". $name ."\"\n";

				$value = $n->value;

/*
				print "VALUE2: \"". $value ."\"\n";
				print "LOWER: ". strtolower($textContent) ."\n";
				print "REPLACE: ". str_replace(' ', '-', $textContent) ."\n";
				print "MANGLED: ". str_replace(' ', '-', strtolower($textContent)) ."\n";
*/
				if ( stripos(strtolower($value), 'quotes-by-') ) {
					$output[] = $textContent;
//					print "FOUND: ". $textContent ." - ". $value ."\n";
				} else {
//					print "SKIPPING: $name\n";
					unset($name);
				}

//				print "---------\n";
			}

//		print "========\n";

		}
	}

	return $output;
}
///////////////////////////

$weatherArray = getWeather($lat, $lon);

//$quoteArray = getQuote();

$sillyQuote = shell_exec($myhome ."/Sources/scripts-git/randomquote.sh");

//print_r($weatherArray['data'][0]['parameters']['wordedForecast']['text']);

$city = $weatherArray['data'][0]['location']['city'];
$today = $weatherArray['data'][0]['parameters']['wordedForecast']['text'][0];
$tonight = $weatherArray['data'][0]['parameters']['wordedForecast']['text'][1];
$quote = $quoteArray[0];
$author = $quoteArray[1];

print $day ."'s forecast for $city is ";
print strtolower($today) ."\n";
print "Tonight will be ". strtolower($tonight) ."\n\n";
//print "$author once said:\n";
//print "$quote\n\n";
print "Today's thought:\n";
print "$sillyQuote\n";
