#!/usr/bin/php
<?php

$xarray = array();

if (($handle = fopen("ips.txt", "r")) !== FALSE) {

	$every_other = 0;

	while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {

		if ( isset($data[0]) ) {
			$xarray[$data[0]] = array ( "realaddress" => $data[0] );
		}
}

// print_r($xarray);

// sort($xarray);

$length = count($xarray);
$counter = 1;

foreach ($xarray as $host) {

	//////////////////////////
	// Strip port from RealAddress

	$realaddress_explode = explode(':', $host["realaddress"]);
	$realaddress = $realaddress_explode[0];
	//////////////////////////


	//////////////////////////
	// GeoIP

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

	print "IP: $realaddress || LOC: $location\n";
	}
}
?>
