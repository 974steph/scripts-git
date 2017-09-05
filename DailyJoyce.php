#!/usr/bin/env php
<?php

$verbose = TRUE;

date_default_timezone_set('America/New_York');
$day = date("l");

// West Chester
$lat = "39.967747";
$lon = "-75.572458";

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
function doCURL() {

	global $verbose;

	$curl = flushCurl();

	$url = "https://www.joycemeyer.org/dailydevo";

//	print "DO CURL: $lat, $lon, $action\n";
	print "URL: $url\n";

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

//	$outputRAW = curl_exec($curl);
//	print $outputRAW;

	libxml_use_internal_errors(true);
	$dom = new DOMDocument;
	$dom->strictErrorChecking = false;
	$dom->preserveWhiteSpace = false;
	$dom->saveHTML();
	$devoDOM = $dom->loadHTML(curl_exec($curl));

//	$result = file_get_contents($url);
//	$devoDOM = $dom->loadHTML($result);

	libxml_use_internal_errors(false);

//	print_r($devoDOM);
//	print_r($dom);

	$content = $dom->getElementsByTagname('p');
//	print_r($content);

	$out = array();

	foreach ($content as $item) {
//		print "FOREACH: ". print_r($item) ."\n";
//		print "FOREACH: ". print_r($item) ."\n";

		if ( strlen($item->nodeValue) > 0 ) {
			$out[] = $item;
//			$out[] = $item->nodeValue;
//			$out[] = array($item => $item->nodeValue);
//			print "attributes: ". $item->attributes ."\n";
//			print_r($item->nodeValue);
		}
	}

//	var_dump($out);
	print_r($out[7]);

exit();


//	$outputXML = new SimpleXMLElement($outputRAW);
//	$outputJSON = json_decode($outputRAW, TRUE);
//	print_r($outputXML);

//	return $outputXML;
	return $dom;
}
///////////////////////////


$devoXML = doCurl();
print_r($devoXML);

?>
