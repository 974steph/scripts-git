#!/usr/bin/env php
<?php

include $_SERVER['HOME'] ."/Sources/scripts-git/secret_stuff.php";

$xarray = array();

$file = "$myhome/Scripts/ips.txt";

if (($handle = fopen($file, "r")) !== FALSE) {

	while (($data = fgetcsv($handle, filesize($file), " ")) !== FALSE) {

		if ( isset($data[0]) ) {
			$xarray[$data[0]] = array (
				"count" => $data[0],
				"realaddress" => $data[1]);
		}
	}

// print_r($xarray);

$length = count($xarray);
$counter = 1;

foreach ($xarray as $host) {

	$count = $host['count'];

	//////////////////////////
	// Strip port from RealAddress

	$realaddress_explode = explode(':', $host["realaddress"]);
	$realaddress = $realaddress_explode[0];
	//////////////////////////


	//////////////////////////
	// GeoIP

//	echo "realaddress: $realaddress\n";

	$record = geoip_record_by_name($realaddress);

	if ($record) {
// 		print_r($record) ."===========================\n";

		if ( $record['city'] == "" || $record['region'] == "" ) {
// 			echo "You are in: ". $record['country_name'] ."\n";;
			$location = $record['country_name'];
		} else {
			if ( isset($record['city']) && isset($record['region'])) {
				if ( $record['country_code'] != "US" ) {
// 					echo "You are in: ". $record['city'] .", ". $record['country_name'] ."\n";
					$location = $record['city'] .", ". $record['country_name'];
				} else {
// 					echo "You are in: ". $record['city'] .", ". $record['region'] ."\n";
					$location = $record['city'] .", ". $record['region'];
				}
			}
		}
	} else {
		$location = "UNKNOWN";
	}
	//////////////////////////

	print "$count\t$realaddress\t$location\n";
	}
}
?>
