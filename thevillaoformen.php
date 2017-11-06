#!/usr/bin/env php
<?php

include 'secret_stuff.php';

$debug = False;
//$debug = True;

$rssurl = "http://thevillaoformen.tumblr.com/rss";
$imageRepo = $myhome ."/Pictures/thevillaoformen";
$shasumsCSV = $imageRepo ."/shasums.csv";


function loadSHASums($shasumsCSV) {

	global $debug;

	$shasums = array();
	$csvCounter = 0;
	$file = fopen($shasumsCSV,"r");

	while (($data = fgetcsv($file)) !== FALSE) {
		$shasums[$csvCounter] = $data;
		$csvCounter++;
	}

	fclose($file);
	return $shasums;
}

function verifySHA($ormenImage,$shasums) {

	global $debug;

//	if (! isset($shasums)) { $shasums = loadSHASums($shasumsCSV); }
//	print_r($shasums);

	$ormenImage['shasum'] = sha1_file($ormenImage['imgURL']);

	$ormenImage['save'] = False;

	if (array_search($ormenImage['shasum'], array_column($shasums, 0))) {
		if ($debug) { print "DUPLICATE: ". $ormenImage['shasum'] ." for ". $ormenImage['filename'] ."\n"; }
	} else {
		if ($debug) { print "NO SHASUM: ". $ormenImage['shasum'] ."\n"; }
		$ormenImage['save'] = True;
	}

	return $ormenImage;
}

function fetchAndUpdate($ormenImage) {

	global $debug, $shasumsCSV;

	if ($debug) { print "Fetching ". $ormenImage['imgURL'] ."\n"; }
	file_put_contents($ormenImage['fullImgPath'], file_get_contents($ormenImage['imgURL']));

	if ($debug) { print "Recording ". $ormenImage['shasum'] .",". $ormenImage['filename'] ." to $shasumsCSV\n"; }
	$shasumsCSVfh = fopen($shasumsCSV,"a");
	fputcsv($shasumsCSVfh, array($ormenImage['shasum'],$ormenImage['filename']));
	fclose($shasumsCSVfh);
}

function getRawRss($rssurl) {

	global $debug;

	try {
		$rawRSS = file_get_contents("http://thevillaoformen.tumblr.com/rss");
		$xml_object = simplexml_load_string($rawRSS);
	} catch (Exception $e) {
		echo 'file_get_contents Caught exception: ',  $e->getMessage(), "\n";
		$xml_object = False;
	}

	return $xml_object;
}


function doSlack($ormenImage) {

	global $debug, $slackEndPoint;

	if ($debug) { print_r($ormenImage); }

	$title = $ormenImage['title'];
	$imgURL = $ormenImage['imgURL'];
	$desc = $ormenImage['desc'];


	if ($debug) {
		print "TITLE: $title\n";
		print "URL: $imgURL\n";
		print "DESC: $desc\n";
	}


	// Create a constant to store your Slack URL
	if ( ! defined('SLACK_WEBHOOK') ) {
		define('SLACK_WEBHOOK', $slackEndPoint);
	}

	// Make your message

	if ( strlen($desc) > 0 ) {
//		$payloadText = "$desc\n\n$imgURL";
		$payloadText = "$imgURL\n\n$desc";
	} else {
		$payloadText = "$imgURL";
	}

	$payload = json_encode(array("text" => "$payloadText", "title" => "$title"), JSON_UNESCAPED_SLASHES);

//	$message = array('payload' => json_encode(array("fields" => array("title" => "$title", "value" => "$imgURL"))));
	$message = str_replace('\"','"', array("payload" => "$payload"));

	if ($debug) {
		print "PAYLOAD:\n$payload\n";
		print_r($message);
	}

	// Use curl to send your message
	$c = curl_init(SLACK_WEBHOOK);
	curl_setopt($c, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($c, CURLOPT_POST, true);
	curl_setopt($c, CURLOPT_POSTFIELDS, $message);
	curl_exec($c);
//	print "\nSLACK\n\n";
	curl_close($c);
}


function makeFilename($ormenImage) {

	global $debug, $imageRepo;

	$info = new SplFileInfo($ormenImage['imgURL']);
	$ormenImage['filename'] = date('Ymd_His', $ormenImage['ts']) .".". $info->getExtension();
	$ormenImage['fullImgPath'] = $imageRepo."/". $ormenImage['filename'];

	if ($debug) { print "makeFilename --> fullImgPath: ". $ormenImage['fullImgPath'] ."\n"; }

	return $ormenImage;
}



$xml_object = getRawRss($rssurl);

if ( ! $xml_object ) {
	echo "xml_object: \""+ $xml_object +"\"\n";
	exit(1);
}

$shasums = loadSHASums($shasumsCSV);
$x = 0;
$ormenImages = array();

foreach ($xml_object->channel->item as $item) {

	if ($item->title == "Photo") {

//		print_r($item);

		$DDoc = new DOMDocument();
		$DDoc->normalizeDocument();
		$DDoc->loadHTML($item->description);
		libxml_use_internal_errors(false);

		foreach( $DDoc->getElementsByTagName('img') as $img) {
			$ormenImages[$x]['imgURL'] = $img->getAttribute('src');
		}

		$ormenImages[$x]['date'] = (string) trim($item->pubDate);
		$ormenImages[$x]['ts'] = strtotime($item->pubDate);
		$ormenImages[$x]['link'] = (string) trim($item->link);
		$ormenImages[$x]['title'] = trim(str_replace(array("\n", "\t", "\r"), '', strip_tags($item->title)));
		$ormenImages[$x]['desc'] = trim(str_replace(array("\n", "\t", "\r"), '', strip_tags($item->description)));
//		$ormenImages[$x]['']

		$ormenImages[$x] = makeFilename($ormenImages[$x]);

		if ( ! is_file($ormenImages[$x]['fullImgPath']) ) {

			if ($debug) { print "NO FILE: ". $ormenImages[$x]['fullImgPath'] ."\n"; }

			$ormenImages[$x] = verifySHA($ormenImages[$x],$shasums);

			if ($ormenImages[$x]['save']) {
				if ($debug) { print "SELECTING ". $ormenImages[$x]['filename'] ."\n"; }
				$x++;
			}
		} else {
			if ($debug) { print "SKIPPING ". $ormenImages[$x]['fullImgPath'] ."\n"; }
			unset($ormenImages[$x]);
		}
	}
}


foreach($ormenImages as $ormenImage) {

	if ($debug) { print_r($ormenImage); }

	fetchAndUpdate($ormenImage);

	doSlack($ormenImage);

	if ($debug) { print "=========\n"; }
}
?>
