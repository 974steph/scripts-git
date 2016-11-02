#!/usr/bin/php
<?php

///////////////////////////
// INPUT
//
// 1) startMin - YYYY-MM-DD
// 2) startMax - YYYY-MM-DD
// 3) lexOnly - TRUE FALSE
// 4) debug - TRUE FALSE
///////////////////////////

// https://developers.google.com/google-apps/calendar/v3/reference/events/list

date_default_timezone_set('US/Eastern');
$argvLength = count($argv);

if ( $argvLength != 5 ) {
	print "NOT ENOUGH ARGUMENTS!\n\n";
	print "1) startMin - YYYY-MM-DD\n";
	print "2) startMax - YYYY-MM-DD\n";
	print "3) lexOnly - TRUE FALSE\n";
	print "4) debug - TRUE FALSE\n\n";
	var_dump($argv);
	exit(1);
} else {
	$startMin = $argv[1];
	$startMax = $argv[2];
	if ( $argv[3] == "TRUE" ) { $lexOnly = TRUE; } else { $lexOnly = FALSE; };
	if ( $argv[4] == "TRUE" ) { $debug = TRUE; } else { $debug = FALSE; };
}

if ( $lexOnly == TRUE ) {
	$tmpDir="/tmp/ForeverTempLex";
} else {
	$tmpDir="/tmp/ForeverTemp";
}

if ( ! is_dir($tmpDir) ) { mkdir($tmpDir, 0755); }

// $sharedCal = "https://calendar.google.com/calendar/ical/c0s7i7b0efq4pf47bkdaf7lfbk%40group.calendar.google.com/private-2fde973cf30e98a7fa64de507bd8eb56/basic.ics?start.date=2016-08-01&end.date=2016-10-01";
$sharedCal = "https://calendar.google.com/calendar/ical/c0s7i7b0efq4pf47bkdaf7lfbk%40group.calendar.google.com/private-2fde973cf30e98a7fa64de507bd8eb56/basic.ics";
// $sharedCal = "https://calendar.google.com/calendar/ical/c0s7i7b0efq4pf47bkdaf7lfbk%40group.calendar.google.com/private-2fde973cf30e98a7fa64de507bd8eb56/";
$icsRawFile = "$tmpDir/cal_raw.ical";
$icsCleanFile = "$tmpDir/cal_raw_clean.ical";
$autoEventDumpFile = "$tmpDir/forever_cal_raw.dump";
$dumpFileString = "";
$finalArray = array();


// $testParams = "?timeMin=2016-07-01T00:00:00-04:00&timeMax=2016-09-01T00:00:00-04:00";
// $rawDUMP = file_get_contents($sharedCal ."". $testParams);
// print $rawDUMP;
// exit();




if ( $debug ) {
	print "startMin: $startMin - ". strtotime($startMin) ."\n";
	print "startMax: $startMax - ". strtotime($startMax) ."\n";
	print "lexOnly: $lexOnly\n";
	print "debug: $debug\n";
	print "tmpDir: $tmpDir\n";
	print "icsRawFile: $icsRawFile\n";
	print "icsCleanFile: $icsCleanFile\n";
	print "autoEventDumpFile: $autoEventDumpFile\n";
	print "dumpFileString: $dumpFileString\n";
// 	print ": \n";
}


///////////////////////////
// FLUSH CURL
function flushCurl() {

	global $verbose, $fh;

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_STDERR, $fh);
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
// SORTING
function sortByStart($a, $b) {
	if ($a['DTSTART'] == $b['DTSTART']) {
		return 0;
	}

	return ($a['DTSTART'] > $b['DTSTART']) ? +1 : -1;
}
///////////////////////////


///////////////////////////
// SORTED AND CLEANED
function sortAndClean($icalArray) {

	global $finalArray;

	$x = 0;

	foreach ( $icalArray as $key=>$thing ) {

		$tmpArray = array();

		if ( $key >= 5 ) {

// 			foreach ($thing as $k=>$v ) {
// 				if ( strpos($k, 'SUMMARY') !== false ) { $finalArray[$x]['SUMMARY'] = trim($v); }
// 				if ( strpos($k, 'DTSTART') !== false ) { $finalArray[$x]['DTSTART'] = trim(strtotime($v)); }
// 				if ( strpos($k, 'DTEND') !== false ) { $finalArray[$x]['DTEND'] = trim(strtotime($v)); }
// 				if ( strpos($k, 'LOCATION') !== false ) { $finalArray[$x]['LOCATION'] = trim(str_ireplace("\x0D", "", str_replace("\\",'',$v))); }
// 				if ( strpos($k, 'CREATED') !== false ) { $finalArray[$x]['CREATED'] = trim(strtotime($v)); }
// 				if ( strpos($k, 'DESCRIPTION') !== false ) { $finalArray[$x]['DESCRIPTION'] = trim(str_ireplace("\x0D", "", str_replace("\\", '',$v))); }
// 				if ( strpos($k, 'STATUS') !== false ) { $finalArray[$x]['STATUS'] = trim($v); }
// 			}

			foreach ($thing as $k=>$v ) {
				if ( strpos($k, 'SUMMARY') !== false ) { $finalArray[$x]['SUMMARY'] = trim($v); }
				if ( strpos($k, 'DTSTART') !== false ) { $finalArray[$x]['DTSTART'] = trim(strtotime($v)); }
				if ( strpos($k, 'DTEND') !== false ) { $finalArray[$x]['DTEND'] = trim(strtotime($v)); }
				if ( strpos($k, 'LOCATION') !== false ) { $finalArray[$x]['LOCATION'] = trim(str_ireplace("\x0D", "", str_replace("\\",'',$v))); }
				if ( strpos($k, 'CREATED') !== false ) { $finalArray[$x]['CREATED'] = trim(strtotime($v)); }
				if ( strpos($k, 'DESCRIPTION') !== false ) { $finalArray[$x]['DESCRIPTION'] = trim(str_ireplace("\x0D", "", str_replace("\\", '',$v))); }
				if ( strpos($k, 'STATUS') !== false ) { $finalArray[$x]['STATUS'] = trim($v); }
			}

			$x++;
		}
	}

	usort($finalArray, "sortByStart");
// 	print_r($finalArray);
}
///////////////////////////


///////////////////////////
// CLEAN CAL
function cleanCal() {

	global $debug, $sharedCal, $tmpDir, $icsRawFile, $icsCleanFile;

// 	$rawDUMP = file_get_contents($sharedCal);
// 	print $rawDUMP;
// 	exit();

	file_put_contents($icsRawFile, fopen($sharedCal, 'r'));

	shell_exec("perl -0pe 's/\r\n //g' < $icsRawFile > $icsCleanFile");
}
///////////////////////////


///////////////////////////
// ICS TO ARRAY
function icsToArray($icsCleanFile) {

	global $debug, $tmpDir, $icsCleanFile;

// 	$icsFile = file_get_contents($icsCleanFile);
	$icsFile = file_get_contents($icsCleanFile);

	$icsData = explode("BEGIN:", $icsFile);

	foreach($icsData as $key => $value) {
		$icsDatesMeta[$key] = explode("\n", $value);
	}

	foreach($icsDatesMeta as $key => $value) {
		foreach($value as $subKey => $subValue) {

			if ($subValue != "") {

				if ($key != 0 && $subKey == 0) {
					$icsDates[$key]["BEGIN"] = $subValue;
				} else {
					$subValueArr = explode(":", $subValue, 2);
					$icsDates[$key][$subValueArr[0]] = $subValueArr[1];
				}
			}
		}
	}

	return $icsDates;
}
///////////////////////////


///////////////////////////
// MAKE DUMP FILE
function makeDumpFile() {

	global $debug, $icalArray, $finalArray, $startMin, $startMax, $autoEventDumpFile, $dumpFileString;

	$dumpFileHandle = fopen($autoEventDumpFile,"w");

// 	foreach ($icalArray as $num=>$apptArray ) {
	foreach ($finalArray as $num=>$apptArray ) {


		if (isset($apptArray['SUMMARY'])) { $apptTitle = $apptArray['SUMMARY']; }
		if (isset($apptArray['DTSTART'])) {$apptStart = $apptArray['DTSTART']; }
		if (isset($apptArray['DTEND'])) { $apptEnd = $apptArray['DTEND']; } else { $apptEnd = 0; }
		if (isset($apptArray['LOCATION'])) { $apptLocaton = $apptArray['LOCATION']; }
		if (isset($apptArray['CREATED'])) { $apptCreated = $apptArray['CREATED']; }
		if (isset($apptArray['DESCRIPTION'])) { $apptNotes = $apptArray['DESCRIPTION']; }
		if (isset($apptArray['STATUS'])) { $apptStatus = $apptArray['STATUS']; }
// 		print "$apptTitle - $apptStart - $apptEnd - $apptLocaton - $apptNotes\n";
// 		print "=========\n";

		if (
			(isset($apptStart) && ($apptStart >= strtotime($startMin) && $apptStart <= strtotime($startMax)))
			||
			(isset($apptEnd) && ($apptStart <= strtotime($startMin) && $apptEnd >= strtotime($startMin)))
			) {

			if ( ! empty($apptTitle)) { $dumpFileString .= "!TITLE=\"$apptTitle\"";}

			if ( ! empty($apptStart) && ! empty($apptEnd)) {
				$startPretty = date('D M j, Y g:ia', $apptStart);
				$endPretty = date('D M j, Y g:ia', $apptEnd);
				$dumpFileString .= "!WHEN_RAW=\"$startPretty to $endPretty\"";
			}

			if ( ! empty($apptLocaton)) { $dumpFileString .= "!LOCATION=\"$apptLocaton\"";}
			if ( ! empty($apptNotes)) { $dumpFileString .= "!CONTENT=\"$apptNotes\"";}
			if ( ! empty($apptStatus)) { $dumpFileString .= "!EVENT_STATUS=\"$apptStatus\"";}
			if ( ! empty($apptCreated)) { $dumpFileString .= "!CREATED=\"$apptCreated\"";}

			$dumpFileString .= "\n";
		}

			if ( $debug ) { print $dumpFileString; }
			fwrite($dumpFileHandle, $dumpFileString);
			$dumpFileString = "";

	}

	fclose($dumpFileHandle);
}
///////////////////////////


///////////////////////////
// DO IT
// print_r(icsToArray($sharedCal));
if ( $debug ) { print "CLEAN CAL\n"; }
cleanCal();

if ( $debug ) { print "ICS TO ARRAY\n"; }
$icalArray = icsToArray($sharedCal);

// print_r($icalArray);
// exit();

if ( $debug ) { print "SORT AND CLEAN\n"; }
sortAndClean($icalArray);

//print_r($finalArray);

if ( $debug ) { print "MAKE DUMP FILE\n"; }
makeDumpFile();

if ( $debug ) {
	print "today: \"$startMin\"\n";
	print "future: \"$startMax\"\n";
}
?>
