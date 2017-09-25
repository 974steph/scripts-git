#!/usr/bin/env php
<?php
date_default_timezone_set('US/Eastern');

$debug = TRUE;

$days = 2;
$today = date('m/d/Y');
$future = date('m/d/Y', strtotime(" +". $days ." days"));
print "TODAY: $today\n";
print "FUTURE: $future\n";
$date1 = new DateTime($today);
$date2 = new DateTime($future);
$diff = $date2->diff($date1)->format("%a");
print "DATE DIFF: $diff days\n";
print "---------------------------\n\n";

///////////////////////////
// CALENDARS
$calurls = array(
	"AcademicSchedule" => array(
		"title" => "Academic Schedule Adjustments",
		"url" => "https://calendar.kutztown.edu/RSSSyndicator.aspx?category=24-0&location=&type=N&starting=". $today ."&ending=". $future ."&binary=Y&ics=Y"
		),
	"Cancelations" => array(
		"title" => "Class Cancelations",
		"url" => "https://calendar.kutztown.edu/RSSSyndicator.aspx?category=51-0&location=&type=N&starting=". $today ."&ending=". $future ."&binary=Y&ics=Y"
		),
	"General" => array(
		"title" => "Lots of Stuff",
		"url" => "https://calendar.kutztown.edu/RSSSyndicator.aspx?category=20-0,32-0,23-0,24-18,24-22,24-19,24-20,24-23,30-0,21-0,51-0,29-0,34-0,22-0,31-0,56-0,66-0,60-0,53-0,26-0,36-0,37-0,39-0,41-0,61-0,42-0,43-0,45-0,50-0&location=&type=N&starting=". $today ."&ending=". $future ."&binary=Y"
		),
	"SocialEvents" => array(
		"title" => "Social Events",
		"url" => "https://calendar.kutztown.edu/RSSSyndicator.aspx?category=47-0&location=&type=N&starting=". $today ."&ending=". $future ."&binary=Y&ics=Y"
		),
	);

/*
	"" => array(
		"title" => "",
		"url" => ""
		),
*/
///////////////////////////


///////////////////////////
// FLUSH CURL
function flushCurl() {

	global $debug;

	$curl = curl_init();
//	curl_setopt($curl, CURLOPT_STDERR, $fh);
	curl_setopt($curl, CURLOPT_FAILONERROR, false);
	curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
	curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_FRESH_CONNECT, true);
	curl_setopt($curl, CURLINFO_HEADER_OUT, true);
	curl_setopt($curl, CURLOPT_VERBOSE, false);
	curl_setopt($curl, CURLOPT_HEADER, false);

        return $curl;
}
///////////////////////////


///////////////////////////
// GET RAW CAL
function getRawCal($calurl) {

	global $debug;

	$curl = flushCurl();

	curl_setopt($curl, CURLOPT_URL, "$calurl");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");
	curl_setopt($curl, CURLOPT_HTTPHEADER, array(
		"Content-Type: application/xml"
		));

	$xml_object = simplexml_load_string(curl_exec($curl));

	return $xml_object;
}
///////////////////////////


///////////////////////////
// CURRENT APPOINTMENTS ARRAY
function currentApptsArray($xmlRawCal) {

	$currentAppts = array();
	$x = 0;

	foreach ($xmlRawCal->channel->item as $appt) {

		$patterns = array("/\n/", "/ +/", "/]]>/", "/<!\[CDATA\[/");

		if ( ! preg_match("/Campus Tour/i", $appt->title)) {

//			print "USEING: ". trim($appt->title) ."\n";
//			print "\t". trim($appt->title) ."\n";

			$description = trim(preg_replace($patterns, " ", $appt->description));

			$cleanURL = array('/&type=&rss=rss/', '/\R/');
			$currentAppts[$x]['title'] = trim($appt->title);
//			$currentAppts[$x]['link'] = trim(preg_replace('/\R/','',$appt->link));
			$currentAppts[$x]['link'] = trim(preg_replace($cleanURL,'',$appt->link));

			if ( strlen($description) > 1 ) {
				$currentAppts[$x]['description'] = $description;
			} else {
				$currentAppts[$x]['description'] = "";
			}

			$currentAppts[$x]['pubDate'] = trim($appt->pubDate);
			$currentAppts[$x]['category'] = trim($appt->category);
		} else {
			print "SKIPPING: ". trim($appt->title) ."\n";
		}

		$x++;
	}

	return $currentAppts;
}
///////////////////////////


foreach ($calurls as $key => $val) {
//	print "$key\n";

	$xmlRawCal = getRawCal($calurls[$key]['url']);

	getRawCal($calurls[$key]['url']);

	$currentAppts = currentApptsArray($xmlRawCal);

	if ( count($currentAppts) ) {
//		print_r($currentAppts);
		print $calurls[$key]['title'] ." - ". count($currentAppts) ." total appointments\n";
	} else {
		print $calurls[$key]['title'] ." - ". count($currentAppts) ." total appointments\n";
	}

//	print_r($currentAppts);

	foreach ($currentAppts as $current) {
		print "\t". $current['title'] ."\n";
		print "\t\t". $current['link'] ."\n";
	}

//	$date1 = new DateTime($today);
//	$date2 = new DateTime($future);
//	$diff = $date2->diff($date1)->format("%a");
//	print "DATE DIFF: $diff\n";
	print "\n========================\n";
}

exit();


//print_r ($calurls);
//$xmlRawCal = getRawCal($calurls['AcademicSchedule']['url']);
//$xmlRawCal = getRawCal($calurls['Cancelations']['url']);
//$xmlRawCal = getRawCal($calurls['NoSub']['url']);
$xmlRawCal = getRawCal($calurls['SocialEvents']['url']);

print_r($xmlRawCal);
exit();

getRawCal($calurls['SocialEvents']['url']);

$currentAppts = currentApptsArray($xmlRawCal);

if ( count($currentAppts) ) {
	print_r($currentAppts);
	print "Calendar: ". $calurls['AcademicSchedule']['title'] ." - ". count($currentAppts) ." total appointments\n";
} else {
	print "Calendar: ". $calurls['AcademicSchedule']['title'] ." - ". count($currentAppts) ." total appointments\n";
}

$date1 = new DateTime($today);
$date2 = new DateTime($future);
$diff = $date2->diff($date1)->format("%a");
print "DATE DIFF: $diff\n";

?>
