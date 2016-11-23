#!/usr/bin/env php
<?php

include $_SERVER['HOME'] ."/Sources/scripts-git/secret_stuff.php";

date_default_timezone_set('US/Eastern');
libxml_use_internal_errors(true);

$debug = TRUE;

$rawRSS = file_get_contents("http://nightvale.libsyn.com/rss");
$xml = new SimpleXMLElement($rawRSS);
unset($rawRSS);

$tank = "$myhome/NightVale";


if ( count($argv) > 1 ) {

	if ( $argv[1] == "get" ) {
		$getShow = TRUE;
	} else {
		$getShow = FALSE;
	};
}


function parseInfo($description) {

	global $debug, $summary, $weather;

// 	if ( $debug == TRUE ) { print "---------\n$description\n---------\n"; }

	$doc = new DOMDocument();
	$doc->loadHTML($description);

	$arr = $doc->getElementsByTagName("p");

	$x = 0;

	foreach($arr as $item) {

//		print_r($item);

		if ( $x == 0 ) { $summary = $item->textContent; }
//		if ( $x == 1 ) { $weather = str_replace('Weather: ', '', $item->textContent); }
		if ( preg_match('/[wW]eather: /', $item->textContent) ) { $weather = str_replace('Weather: ', '', $item->textContent); }

//		print "$x - \"$item->textContent\"\n";

		$x++;
	}

	$x = 0;
}


function downloadFile($url, $tank, $fileMp3) {

	global $debug;

	if ( ! is_dir("$tank") ) {

		print "\"$tank\" is not a dir.\n";

		mkdir ("$tank", 0755);

//	} else {
//		print "\"$tank\" exists!\n";
	}

	if ( $debug == TRUE ) { print "DOWNLOAD $url --> $tank/$fileMp3\n"; }

	file_put_contents("$tank/$fileMp3", fopen("$url", 'r'));
}


function safeName($title) {

	global $debug, $fileMp3;

	if ( preg_match('/^[0-9] /', $title) ) {
		$title = "0$title";
	}

	$find = array('/\.$/', '/\[/', '/\]/', '/\"/', '/\?/');
// 	$replace = array('', '', '', '', '', ' - ');
// 	$result = preg_replace($find, $replace, $title);
	$result = preg_replace($find, '', $title);

	$result = preg_replace('/:/', ' - ', $result);
	$result = preg_replace('/ +/', ' ', $result);

	$fileMp3 = $result .".mp3";
}

// print_r($xml);
// exit();

global $getShow;

foreach ($xml->channel->item as $k=>$v) {

	global $debug, $fileMp3, $summary, $weather;

	$title = $v->title;
	$pubDate = $v->pubDate;
	$description = $v->description;
	$epoch = strtotime($pubDate);

	safeName($title);

	$title = preg_replace('/^[0-9]+ - /', '', $title);
// 	$fileMp3 = $title .".mp3";

	if ( is_file("$tank/$fileMp3") ) {
//		print "YES: $tank/$fileMp3\n";
		$haveEpisode = TRUE;
	} else {
//		print "NO: $tank/$fileMp3\n";
		$haveEpisode = FALSE;
	}

	$rerun = strpos($title, '(R)');
//	if ( $debug == TRUE ) { print "RERUN: ". strpos($title, '(R)') ."\n"; }

	if ( ($haveEpisode == FALSE) AND (! $rerun) ) {
		print "$title - \"$fileMp3\"\n";
		print "$epoch - $pubDate\n";
		parseInfo($description);
		print "$summary\n";
		print "$weather\n";

		$url = $v->enclosure->attributes()->url;
		print "$url\n";
		print "NO: $tank/$fileMp3\n";
	} else {
		print "$title - \"$fileMp3\"\n";

		if ( $rerun ) {
			print "RERUN\n";
		} else {
			print "YES: $tank/$fileMp3\n";
		}
	}

	if ( ($getShow) AND (! $haveEpisode) ) {
		downloadFile($url, $tank, $fileMp3);
	}

// 	shell_exec("id3v2 --TEXT \"$summary\" --comment \"$summary\" --song \"$title\" --genre 57 \"$tank/$fileMp3\"");

	print "=========\n";
}

exit();

?>

