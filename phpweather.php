<?php

// curl "localhost/weathertest.php?loc=bend&long=true"

///////////////////////////
date_default_timezone_set('UTC');
$day = date("l");

$locations = array(
	"albuquerque" => array(
		"title" => "Albuquerque",
		"latitude" => "35.113281",
		"longitude" => "-106.621216"
		),
	"bend" => array(
		"title" => "Bend",
		"latitude" => "44.058174",
		"longitude" => "-121.315308"
		),
	"kutztown" => array(
		"title" => "Kutztown",
		"latitude" => "40.508181",
		"longitude" => "-75.782635"
		),
	"santafe" => array(
		"title" => "Santa Fe",
		"latitude" => "35.6870",
		"longitude" => "-105.9378"
		),
	"westchester" => array(
		"title" => "West Chester",
		"latitude" => "39.967747",
		"longitude" => "-75.572458"
		)
	);

/*
	"" => array(
		"title" => "",
		"latitude" => "",
		"longitude" => ""
		),
*/
///////////////////////////

$forecastLong = FALSE;
$tomorrowLong = FALSE;
$location = "westchester";

if (count($_GET) > 0) {

//	print_r($_GET);

	foreach ($_GET as $k=>$v) {
//		print "k: $k || v: $v\n";
		if (trim($k) == "long" and trim($v) == "true") {
			$forecastLong = TRUE;
			$tomorrowLong = TRUE;
		} elseif (trim($k) == "long" and trim($v) == "false") {
			$forecastLong = FALSE;
			$tomorrowLong = FALSE;
		} elseif (trim($k) == "loc") {
//		} elseif ($k == "loc") {
			$location = strtolower(trim($v));

			if (! array_key_exists($location, $locations)) {
				print "\"$location\" is NOT a valid location\nk: \"$k\"\n";
				exit(1);
//			} else {
//				print "YES, $location is valid\n";
			}
		} elseif ($k = "latlon") {
//			print "got: $k\n";
			$latlon = explode(',', trim($v));
			$latitude = $latlon[0];
			$longitude = $latlon[1];
			print "Lat: $latitude || Lon: $longitude\n\n";
//			print_r($latlon);
		} else {
			$forecastLong = FALSE;
			$tomorrowLong = FALSE;
			$location = "westchester";
		}
	}
}

$lat = trim($locations[$location]['latitude']);
$lon = trim($locations[$location]['longitude']);
$locName = trim($locations[$location]['title']);

/*
print "forecastLong: $forecastLong\n";
print "tomorrowLong: $tomorrowLong\n";
print "location: $location\n";
print "locName: $locName\n";
print "lat: $lat\n";
print "lon: $lon\n";
*/


//https://api.weather.gov/points/39.9677,-75.5725
//https://api.weather.gov/points/39.9677,-75.5725/forecast
//https://api.weather.gov/points/39.9677,-75.5725/stations


///////////////////////////
// FLUSH CURL
//
function flushCurl() {

	global $verbose, $fh;

	$curl = curl_init();
//	if ( file_exists($fh) ) {
		curl_setopt($curl, CURLOPT_STDERR, $fh);
//	}
	curl_setopt($curl, CURLOPT_USERAGENT,'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36');
//	curl_setopt($curl, CURLOPT_USERAGENT,'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.13) Gecko/20080311 Firefox/2.0.0.13');
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
function doCURL($lat, $lon, $action) {


	$curl = flushCurl();


	if ( isset($action) ) {
		$url = "https://api.weather.gov/points/". $lat .",". $lon ."/". $action ."";
	} else {
		$url = "https://api.weather.gov/points/". $lat .",". $lon ."";
	}

/*
	print "DO CURL: $lat, $lon, $action\n";
	print "URL: $url\n";
*/

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
function getWeather($lat, $lon) {

	$weatherArray = array();

//	$station = doCURL($lat, $lon, "stations");
//	$stationName = explode(',', $station['features'][0]['properties']['name']);
//	$stationName = trim($stationName[1]);
//	$weatherArray['stationName'] = $stationName;

//	print "stationName: $stationName\n";

	$forecast = doCURL($lat, $lon, "forecast");

	$weatherArray['today'] = array(
		'detailedForecast' => $forecast['properties']['periods'][0]['detailedForecast'],
		'shortForecast' => $forecast['properties']['periods'][0]['shortForecast'],
		'temperature' => $forecast['properties']['periods'][0]['temperature']
		);
	$weatherArray['tonight'] = array(
		'detailedForecast' => $forecast['properties']['periods'][1]['detailedForecast'],
		'shortForecast' => $forecast['properties']['periods'][1]['shortForecast'],
		'temperature' => $forecast['properties']['periods'][1]['temperature']
		);
	$weatherArray['tomorrow'] = array(
		'detailedForecast' => $tomorrowForecast = $forecast['properties']['periods'][2]['detailedForecast'],
		'shortForecast' => $tomorrowForecast = $forecast['properties']['periods'][2]['shortForecast'],
		'temperature' => $forecast['properties']['periods'][2]['temperature']
		);

//	print_r($weatherArray);

	return $weatherArray;
}
///////////////////////////


///////////////////////////
// GET SERIOUS QUOTE
//
function getSeriousQuote() {

	$curl = flushCurl();

	$url = "http://www.motivationalquotes101.com";

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

	$outputRAW = curl_exec($curl);

	$dom = new DOMDocument;
	$dom->loadHTML($outputRAW);

	foreach($dom->getElementsByTagName('strong') as $node) {

		if ($node->textContent) {
			$output[] = $node->textContent;
		}
	}

	foreach($dom->getElementsByTagName('a') as $node) {

		if ( strlen($node->textContent) > 0) {

			$textContent = $node->textContent;

			foreach ($node->attributes as $n) {

				$value = $n->value;

				if ( stripos(strtolower($value), 'quotes-by-') ) {
					$output[] = $textContent;
				} else {
					unset($name);
				}
			}
		}
	}

	return $output;
}
///////////////////////////



///////////////////////////
// GET SILLY QUOTE
//
function getSillyQuote() {

	$curl = flushCurl();

	$url = "http://www.lolsotrue.com";

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

	$outputRAW = curl_exec($curl);

	$dom = new DOMDocument;
	$dom->loadHTML($outputRAW);
//	print_r($dom);

	foreach($dom->getElementsByTagName('image') as $node) {


		print_r($node);

		if ($node->textContent) {
			$output[] = $node->textContent;
		}
	}

	return $output;
}
///////////////////////////


$fortune = strtolower(shell_exec('fortune chalkboard | head -n1'));

$weatherArray = getWeather($lat, $lon);

//print_r($weatherArray);

//$city = $weatherArray['stationName'];
$city = $locations[$location]['title'];

if ( $tomorrowLong ) {
	$tomorrow = "Tomorrow might be ". $weatherArray['tomorrow']['detailedForecast'];
} else {
	$tomorrow = "Tomorrow might be ". $weatherArray['tomorrow']['shortForecast'] ." with a high of ". $weatherArray['tomorrow']['temperature'];
}

if ( $forecastLong ) {
//	print "TRUE $forecastLong\n";
	print $day ."'s forecast for $city is ";
	print $weatherArray['today']['detailedForecast'] ."\n\n";
	print "Tonight will be ". $weatherArray['tonight']['detailedForecast'] ."\n\n";
	print $tomorrow ."\n\n";
	print "$fortune\n";
} else {
//	print "FALSE $forecastLong\n";
	print $day ."'s forecast for $city is ";
	print $weatherArray['today']['shortForecast'] ."\n\n";
	print "Tonight will be ". $weatherArray['tonight']['shortForecast'] ."\n\n";
	print $tomorrow ."\n\n";
	print "$fortune\n";
}
