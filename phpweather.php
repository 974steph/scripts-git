<?php

$forecastLong = TRUE;
$tomorrowLong = FALSE;

//https://api.weather.gov/points/39.9677,-75.5725
//https://api.weather.gov/points/39.9677,-75.5725/forecast
//https://api.weather.gov/points/39.9677,-75.5725/stations

//include $_SERVER['HOME'] ."/Sources/scripts-git/secret_stuff.php";

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
function doCURL($lat, $lon, $action) {


	$curl = flushCurl();


	if ( isset($action) ) {
		$url = "https://api.weather.gov/points/". $lat .",". $lon ."/". $action ."";
	} else {
		$url = "https://api.weather.gov/points/". $lat .",". $lon ."";
	}

//	print "DO CURL: $lat, $lon, $action\n";
//	print "URL: $url\n";

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


	$station = doCURL($lat, $lon, "stations");
//	print_r($station['features'][0]);
	$stationName = $station['features'][0]['properties']['name'];
	$stationName = explode(',', $stationName);
//	print_r($stationName);
	$stationName = trim($stationName[1]);
//	print "stationName: $stationName\n";


	$forecast = doCURL($lat, $lon, "forecast");

//	$todayForecast = $forecast['properties']['periods'][0]['detailedForecast'];
	$todayForecast = $forecast['properties']['periods'][0]['shortForecast'];
	$todayTemp = $forecast['properties']['periods'][0]['temperature'];
//	print_r($todayArray);
//	print "TODAY: $today\n";

//	$tonightForecast = $forecast['properties']['periods'][1]['detailedForecast'];
	$tonightForecast = $forecast['properties']['periods'][1]['shortForecast'];
	$tonightTemp = $forecast['properties']['periods'][1]['temperature'];
//	print "TONIGHT: $tonight\n";

	$tomorrowForecast = $forecast['properties']['periods'][2]['shortForecast'];
	$tomorrowTemp = $forecast['properties']['periods'][2]['temperature'];

//	print "TOMORROW: $tomorrowForecast with a high of $tomorrowTemp\n";


	$weatherArray = array(
		'stationName' => $stationName,
		'today' => array(
			'detailedForecast' => $forecast['properties']['periods'][0]['detailedForecast'],
			'shortForecast' => $forecast['properties']['periods'][0]['shortForecast'],
			'temperature' => $forecast['properties']['periods'][0]['temperature']
			),
		'tonight' => array(
			'detailedForecast' => $forecast['properties']['periods'][1]['detailedForecast'],
			'shortForecast' => $forecast['properties']['periods'][1]['shortForecast'],
			'temperature' => $forecast['properties']['periods'][1]['temperature']
			),
		'tomorrow'=> array(
			'detailedForecast' => $tomorrowForecast = $forecast['properties']['periods'][2]['detailedForecast'],
			'shortForecast' => $tomorrowForecast = $forecast['properties']['periods'][2]['shortForecast'],
			'temperature' => $forecast['properties']['periods'][2]['temperature']
			)
		);

//	print_r($weatherArray);
//exit();
	return $weatherArray;

//exit();
//	$curl = flushCurl();

////	$url = "http://forecast.weather.gov/MapClick.php?lat=". $lat ."&lon=". $lon ."&unit=0&lg=english&FcstType=dwml";
//	$url = "https://api.weather.gov/points/". $lat .",". $lon ."/forecast";

// 	print "URL: $url\n";

//	curl_setopt($curl, CURLOPT_URL, "$url");
//	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

//	$outputRAW = curl_exec($curl);
//	print $outputRAW;

//	$output = json_decode(json_encode(simplexml_load_string($outputRAW)), TRUE);
//	$output = json_decode($outputRAW, TRUE);
//	var_dump($output['properties']['periods'][0]['detailedForecast']);
//	print $output['properties']['periods'][0]['detailedForecast'] ."\n";



//	return $output;
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

//	return $outputRAW;
	return $output;
}
///////////////////////////


$fortune = shell_exec('fortune chalkboard | head -n1');

$weatherArray = getWeather($lat, $lon);

//print_r($weatherArray);

$city = $weatherArray['stationName'];

/*
$today = $weatherArray['today']['todayForecast'];
$tonight = $weatherArray['tonight']['tonightForecast'];
$tomorrowForecast = $weatherArray['tomorrow']['tomorrowForecast'];
$tomorrowTemp = $weatherArray['tomorrow']['tomorrowTemp'];
*/

if ( $tomorrowLong ) {
	$tomorrow = $weatherArray['tomorrow']['detailedForecast'];
} else {
	$tomorrow = "Tomorrow might be ". $weatherArray['tomorrow']['shortForecast'] ." with a high of ". $weatherArray['tomorrow']['temperature'];
}

if ( $forecastLong ) {
//	print "TRUE $forecastLong\n";
	print $day ."'s forecast for $city is ";
	print $weatherArray['today']['detailedForecast'] ."\n\n";
	print "Tonight will be ". $weatherArray['tonight']['detailedForecast'] ."\n\n";
//	print "Tomorrow might be ". $weatherArray['tomorrow']['detailedForecast'] ." with a high of ". $weatherArray['tomorrow']['temperature'] .".\n\n";
	print $tomorrow ."\n\n";
	print "$fortune\n";
} else {
//	print "FALSE $forecastLong\n";
	print $day ."'s forecast for $city is ";
	print $weatherArray['today']['shortForecast'] ."\n\n";
	print "Tonight will be ". $weatherArray['tonight']['shortForecast'] ."\n\n";
//	print "Tomorrow might be ". $weatherArray['tomorrow']['shortForecast'] ." with a high of ". $weatherArray['tomorrow']['temperature'] .".\n\n";
	print $tomorrow ."\n\n";
	print "$fortune\n";
}

exit();



print $day ."'s forecast for $city is ";
print "$today\n\n";
print "Tonight will be $tonight\n\n";
print "Tomorrow might be $tomorrowForecast with a high of ". $tomorrowTemp .".\n\n";
print "$fortune\n";

exit();

//$quoteArray = getSeriousQuote();
//$quote = $quoteArray[0];
//$author = $quoteArray[1];


//print_r($weatherArray['data'][0]['parameters']['wordedForecast']['text']);

$city = $weatherArray['data'][0]['location']['city'];
$today = $weatherArray['data'][0]['parameters']['wordedForecast']['text'][0];
$tonight = $weatherArray['data'][0]['parameters']['wordedForecast']['text'][1];

print $day ."'s forecast for $city is ";
print strtolower($today) ."\n\n";
print "Tonight will be ". strtolower($tonight) ."\n\n";

//print "$author once said:\n";
//print "$quote\n\n";

//print "Today's thought:\n";

//$sillyQuote = shell_exec("randomquote.sh");
//print "\n\n\n$sillyQuote\n";

//$fortune = shell_exec('fortune chalkboard | head -n1');
//$fortune = shell_exec('fortune -s definitions | egrep -v "^[a-zA-Z0-9].*:|^[\t ]\+--" | sed "s/^[\t ]\+//g" | tr \\n " "');
//$fortune = shell_exec('fortune -s | egrep -v "^[a-zA-Z0-9].*:|^[\t ]\+--" | sed "s/^[\t ]\+//g" | tr \\n " "');
//print "FORTUNE: $fortune\n";
//exit();
//$sillyQuote = getSillyQuote();
//print_r($sillyQuote);
//exit();
print "\n\n$fortune\n";
