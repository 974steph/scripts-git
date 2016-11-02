#!/usr/bin/php
<?php

date_default_timezone_set('US/Eastern');

error_reporting(E_ALL);

//$priceMax = "20000";
$opts = getopt("hm:M:c:s:",['min','max','class','sort']);

//////////////////
// DEFAULTS
$priceMin = 10000;
$priceMax = 20000;
$sortBy = "price";
//$sortBy = "DateAdded";
//$class = 'c';
//////////////////

function sortByStart($a, $b) {

	//$thisField = "price";

	global $sortBy;

	if ($a[$sortBy] == $b[$sortBy]) { return 0; }
	return ($a[$sortBy] > $b[$sortBy]) ? +1 : -1;

	//if ($a['price'] == $b['price']) { return 0; }
	//return ($a['price'] > $b['price']) ? +1 : -1;
}

function DumpHelp() {

	print "\nCommandline Options\n\n";
	print "-c\tClass\n";
	print "-m\tMinimum proce (Default: )\n";
	print "-M\tMaximum Price (Default: )\n";
	print "-s\tSorting (Default: price.  date, modified)\n";
	print "-h\tDump this help\n";
	print "\n";

	exit(0);
}

if ( isset($opts['h']) ) { print "HELP\n"; DumpHelp(); }

if ( isset($opts['m']) ) { $priceMin = $opts['m']; }
//if ( isset($opts['min']) ) { $min = $opts['min']; }

if ( isset($opts['M']) ) { $priceMax = $opts['M']; }
//if ( isset($opts['max']) ) { $max = $opts['max']; }

if ( isset($opts['c']) ) { $class = strtoupper($opts['c']); }
//if ( isset($opts['class']) ) { $class = $opts['class']; }

if ( isset($opts['s']) ) { $sortBy = $opts['s']; }
//if ( isset($opts['class']) ) { $class = $opts['class']; }

if ( $sortBy == "date" ) { $sortBy = "DateAdded"; }
if ( $sortBy == "modified" ) { $sortBy = "DateModified"; }

$charRAW = file_get_contents("http://www.stoltzfus-rec.com/imglib/Inventory/cache/982/UVehInv.js");

$patterns[0] = '/var Vehicles=/';
$patterns[1] = '/;/';

$charRAW = preg_replace($patterns,'',$charRAW);

$charJSON = json_decode( preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $charRAW), true );

$finalList = array();

foreach ( $charJSON as $i => $e) {

	//print_r($e);

	$finalList[] = $e;
}


usort($finalList, "sortByStart");


$buyableList = array();


foreach ($finalList as $e) {

	global $priceMax, $priceMin, $class, $sortBy;

	/*
	print "prixeMax: $priceMax\n";
	print "priceMin: $priceMin\n";
	print "class: $class\n";
	*/

	if ( ! isset($class) ) {
		if ( (preg_match('/.*Class A.*/',$e['catname']) or preg_match('/.*Class C.*/',$e['catname']))
			and ( ($e['price'] >= $priceMin) and ($e['price'] <= $priceMax) ) ) {
			$buyableList[] = $e;
		}

	} else {

		if ( (preg_match("/.*Class $class.*/",$e['catname']))
			and ( ($e['price'] >= $priceMin) and ($e['price'] <= $priceMax) ) ) {

			$buyableList[] = $e;
		}
	}
}

//Class A


foreach ($buyableList as $e) {

	$price = money_format('%n',$e['price']);
	//$price = money_format('%(#10n',$e['price']);

	$humanAdded = date('Y-m-d',$e['DateAdded']);
	$humanModified = date('Y-m-d',$e['DateModified']);

	//print $e['manuf'] ." ". $e['model'] .": ". $e['price'] ."\n";
	//print $e['manuf'] ." ". $e['model'] .": ". $price ."\n";
	print $e['bike_year'] ." ". $e['manuf'] ." ". $e['model'] ." ". $e['category'] ." (". $e['catname'] ."): $". $price ." || Added: ". $humanAdded ." || Modified: ". $humanModified ."\n";

//	print preg_match('/.*Class A.*/',$e['catname']) ." CLASS A - ". $e['catname'] ."\n";
//	print preg_match('/.*Class C.*/',$e['catname']) ." CLASS C - ". $e['catname'] ."\n";

/*
	foreach ($e as $k => $vehicle) {

		//print $vehicle['manuf'] ." ". $vehicle['make'] ."\n";
		print_r($k);
	}
*/

/*
	if ( is_array($e) ) {

		if ( ! ($i == 'shirt' || $i == 'tabard') ) {
			$rows[$i]['name'] = $e['name'];
			$rows[$i]['itemLevel'] = $e['itemLevel'];
			$rows[$i]['icon'] = $e['icon'];
			$rows[$i]['id'] = $e['id'];

			$itot = ($itot + $e['itemLevel']);
		}
	}
*/
}



//http://cdn.dealerspike.com/imglib/v1/300x225/imglib/Assets/Inventory/3A/EC/3AEC6408-2B50-413D-8DAD-5FECEAD6DD57.JPG
//bike_image: 3AEC6408-2B50-413D-8DAD-5FECEAD6DD57.JPG
//image2: 6B03E4CE-B226-4BE3-8DD5-3D58298A5C0D.jpg

/*
foreach ( $charJSON['items'] as $i => $e) {

	if ( is_array($e) ) {

		if ( ! ($i == 'shirt' || $i == 'tabard') ) {
			$rows[$i]['name'] = $e['name'];
			$rows[$i]['itemLevel'] = $e['itemLevel'];
			$rows[$i]['icon'] = $e['icon'];
			$rows[$i]['id'] = $e['id'];

			$itot = ($itot + $e['itemLevel']);
		}
	}
}
*/
?>
