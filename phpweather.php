<?php

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




$weatherArray = getWeather($lat, $lon);

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

$fortune = shell_exec('fortune chalkboard | head -n1');
//$fortune = shell_exec('fortune -s definitions | egrep -v "^[a-zA-Z0-9].*:|^[\t ]\+--" | sed "s/^[\t ]\+//g" | tr \\n " "');
//$fortune = shell_exec('fortune -s | egrep -v "^[a-zA-Z0-9].*:|^[\t ]\+--" | sed "s/^[\t ]\+//g" | tr \\n " "');
//print "FORTUNE: $fortune\n";
//exit();
//$sillyQuote = getSillyQuote();
//print_r($sillyQuote);
//exit();
print "\n\n$fortune\n";
