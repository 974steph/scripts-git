#!/usr/bin/php

<?php
date_default_timezone_set("US/Eastern");

if ( isset($_SERVER['HTTP_USER_AGENT']) ) {
// 	print "<h1>". $_SERVER['HTTP_USER_AGENT'] ."</h1>";
	$browser = TRUE;
} else {
// 	print "$len - NOT A BROWSER\n";
	$browser = FALSE;
}

$chars = array("Fleagus","Flonase","Cashus","Lofar","Xifaxan");
$auctionsName = "auctions.json";
$auctionsFile = "/tmp/$auctionsName";
//$fileURL = "http://us.battle.net/auction-data/52f853e2b29decd29e027d3a17fe1fba/auctions.json";
$now = time();
$nowPretty = date('Y-m-d g:i:sa', $now);
$x = 0;
$itemCount = 0;
$buyoutTotal = 0;
$grandTotRaw = 0;
$grandTotCount = 0;
$grandTotCopper = 0;
$grandTotSilver = 0;
$grandTotGold = 0;

global $auctionsFile, $fileURL, $timeStamp, $stampPretty, $lastModified, $lastModifiedEpoch, $lastModifiedEpochPretty, $verbose;


if ( ! $browser ) {
	$cmdOptions = getopt("hv");

//	$cmdOptionsCount = count($cmdOptions);
//	print "<h1>COUNT: ". count($cmdOptions) ."</h1>\n";
//	print_r($cmdOptions);
//	exit();

//if ( $cmdOptionsCount > 0 ) {

	foreach ( $cmdOptions as $cmdOption => $cmdValue) {

		if ( $cmdOption == "h" ) { DumpHelp(); }
		if ( $cmdOption == "v" ) { $verbose = TRUE; }
	}
}


//---------------------------------------------
function DumpHelp() {

	print "\nHelp\n------------------\n\n";
	print "-h\tHelp: Dump this help\n";
	print "-v\tVerbose: Show every auction's value\n";
	print "\n";
	exit(0);

}
//---------------------------------------------


//---------------------------------------------
function GetMasterURL() {

	global $fileURL, $lastModified, $lastModifiedEpoch, $lastModifiedEpochPretty, $verbose;

	$url = "http://us.battle.net/api/wow/auction/data/dawnbringer";

//	@$masterJSON = file_get_contents("http://us.battle.net/api/wow/auction/data/dawnbringer");
	@$masterJSON = file_get_contents("$url");
	$masterURL = json_decode($masterJSON, true);
	unset($masterJSON);


	$fileURL = $masterURL['files']['0']['url'];
//	$fileURL = "http://us.battle.net/auction-data/52f853e2b29decd29e027d3a17fe1fba/auctions.json";
	$lastModified = $masterURL['files']['0']['lastModified'];
	$lastModifiedEpoch = substr($lastModified, 0, 10);
	$lastModifiedEpochPretty = date('Y-m-d g:i:sa', $lastModifiedEpoch);

	if ( $verbose ) {
		print_r($masterURL);
		print "fileURL: $fileURL\n";
		print "lastModified: $lastModified\n";
		print "lastModifiedEpoch: $lastModifiedEpoch\n";
	}
}
//---------------------------------------------


//---------------------------------------------
function GetJSON() {

	global $auctionsFile, $fileURL, $timeStamp, $stampPretty, $lastModified, $lastModifiedEpochPretty, $verbose, $browser;

	/*
	$head = array_change_key_case(get_headers("$fileURL", TRUE));
	$filesize = $head['content-length'];
	print "Filesize: $filesize\n";
	exit(0);
	*/

	$fileURL = "http://us.battle.net/auction-data/52f853e2b29decd29e027d3a17fe1fba/auctions.json";

	file_put_contents($auctionsFile, fopen($fileURL, 'r'));

	if ( $browser ) {
		print "<p>Got new JSON</p>";
	} else {
		print "\nGot new JSON\n";
	}

	$timeStamp = filemtime($auctionsFile);
	$stampPretty = date('Y-m-d g:i:sa', $timeStamp);
	$timeStamp = filemtime($auctionsFile);
	$stampPretty = date('Y-m-d g:i:sa', $timeStamp);
}
//---------------------------------------------


//---------------------------------------------
function FormatValue($value) {

	$valCopper = substr($value, (strlen($value) -2), 2);
	$valSilver = substr($value, (strlen($value) -4), 2);
	$valGold = substr($value, 0, (strlen($value) -4) );

	if ( empty($valGold) ) { $valGold = 0; }

	$valGold = number_format($valGold);

	return "$valGold G, $valSilver S, $valCopper C";
}
//---------------------------------------------

//---------------------------------------------
function printHead() {

	global $lastModifiedEpochPretty;

?>
<html>
<head>
	<title>Auctions: <?php print "$lastModifiedEpochPretty";?></title>
</head>
<body width="100px">
<?php
}
//---------------------------------------------

//---------------------------------------------
function printTail() {
?>

	</body>
	</html>
<?php
}
//---------------------------------------------

//GetMasterURL();

if ( $browser ) { printHead(); }

if ( ! file_exists($auctionsFile) ) {
	print "$auctionsFile doesn't exist.  Fetching...\n\n";
	GetJSON();
} elseif ( filesize($auctionsFile) == 0 ) {
	print "$auctionsFile is empty.  Fetching...\n\n";
	GetJSON();
} else {
	$timeStamp = filemtime($auctionsFile);
	$stampPretty = date('Y-m-d g:i:sa', $timeStamp);
}

if ( $browser ) {
	print "<p>";
	print "NOW: $nowPretty<br>";
	print "$auctionsName: $stampPretty<br>";
	print "Auction House: $lastModifiedEpochPretty<br>";
	print "</p>";
} else {
	print "NOW: $nowPretty\n";
	print "$auctionsName: $stampPretty\n";
	print "Auction House: $lastModifiedEpochPretty\n\n";
}

$timeDiff = ($now - $timeStamp);
// $timeDiff = ($now - $lastModifiedEpoch);
// print "timeDiff: $timeDiff\n";
// print "now: $now\n";
// print "lastModifiedEpoch: $lastModifiedEpoch\n";
// exit();

// if ( $timeDiff > 3600 || ! file_exists($auctionsFile) || $timeDiff < 0 ) {
// if ( ($timeDiff > 3600) ) {
// 
// 	print "Cached data is ". floor($timeDiff / 60) ." minutes old.\n";
// 	print "$auctionsName: $stampPretty\n";
// 	print "Auction House last updated: $lastModifiedEpochPretty\n";
// 	print "Updating...\n";
// 
// 	GetJSON();
// 
// } elseif ( $lastModifiedEpoch > $timeStamp ) {
if ( $lastModifiedEpoch > $timeStamp ) {

	if ( $browser ) {
		print "<p>";
		print "Auction House update is newer than $auctionsFile<br>";
		print "Auction House: $lastModifiedEpochPretty<br>";
		print "$auctionsName: $stampPretty<br>";
		print "UPDATING...<br>";
		print "</p>";
// 	print "<br>";
	} else {
		print "Auction House update is newer than $auctionsFile\n";
		print "Auction House: $lastModifiedEpochPretty\n";
		print "$auctionsName: $stampPretty\n";
		print "UPDATING...\n";
	}

	GetJSON();
} else {
	/*
	if ( $browser ) {
		print "<p>";
		print "$auctionsFile is ". floor($timeDiff / 60) ." minutes old.<br>";
		print "Auction House last updated: $lastModifiedEpochPretty<br>";
		print "Not updating...<br>";
		print "</p>";
	} else {
		print "$auctionsFile is ". floor($timeDiff / 60) ." minutes old.\n";
		print "Auction House last updated: $lastModifiedEpochPretty\n";
		print "Not updating...\n";
	}
	*/

	GetJSON();
}



@$auctionsJSON = file_get_contents($auctionsFile);
$auctions = json_decode($auctionsJSON, true);
unset($auctionsJSON);

// if ( $browser ) {
// 	print "<table>";
// }

foreach ( $chars as $char ) {

	$char = trim($char);

	if ( $browser ) {
		print "<table border=\"1\" width=\"300px\">";
		print "<tr><td bgcolor=\"black\" align=\"center\"><font color=\"white\"><b>$char</b></font></td></tr>";
	} else {
		print "\n$char\n\n";
	}

	foreach ( $auctions['auctions'] as $i => $e) {

		$owner = $e['owner'];

		if ( trim(strtolower($owner)) === strtolower($char) ) {

			$buyout = $e['buyout'];
			$item = $e['item'];

			if ( empty($gold) ) { $gold = 0; }

			if ( $verbose ) {
				print "Item: $item - ". FormatValue($buyout) ."\n";
			}

			$buyoutTotal += $buyout;

			$itemCount++;
		}

		$x++;
	}

	if ( empty($totGold) ) { $totGold = 0; }

	if ( ($itemCount) == 0 ) {

		if ( $browser ) {
			print "<tr><td>No auctions found for $char</td></tr>";
			print "</table><br>";
		} else {
			print "No auctions found for $char\n";
			print "==================\n";
		}

	} else {

		$average = FormatValue(floor($buyoutTotal / $itemCount));

		if ( $browser ) {
			print "<tr><td>";
			print "Total Auctions: $itemCount<br>";
			print "Average Item Value: $average<br>";
			print "Total Value: ". FormatValue($buyoutTotal) ."<br>";
			print "</table><br>";
		} else {
// 			print "\n";
			print "Total Auctions: $itemCount\n";
			print "Average Item Value: $average\n";
			print "Total Value: ". FormatValue($buyoutTotal) ."\n";
			print "==================\n";
		}
	}

	$grandTotRaw += $buyoutTotal;
	$grandTotCount += $itemCount;

	$x = 0;
	$itemCount = 0;
	$buyoutTotal = 0;
	$copper = 0;
	$silver = 0;
	$gold = 0;
}

if ( $browser) {
	print "<table border=\"1\" width=\"300px\">";
	print "<tr><td bgcolor=\"black\" align=\"center\"><font color=\"white\"><b>SUMMARY</b></font></td></tr>";
	print "<tr><td>";
	print "GrandTotal Items: ". number_format($grandTotCount) ."<br>";
	print "GrandTotal Value: ". FormatValue($grandTotRaw). "<br>";
	print "</td></tr></table>";
} else {
	print "\nGrandTotal Items: ". number_format($grandTotCount) ."\n";
	print "GrandTotal Value: ". FormatValue($grandTotRaw). "\n\n";
}

if ( $browser ) {
	printTail();
}
?>
