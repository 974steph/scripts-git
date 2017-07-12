#!/usr/bin/env php
<?php

if ( ! isset($argv[1]) ) {
	echo "\nYou need to supply an IP:\n\n";
	echo "$argv[0] [IP]\n\n";
	exit();
} else {
	$realaddress = $argv[1];
}


//////////////////////////
// GeoIP

if ( preg_match('/^172/', $realaddress) == FALSE ) {
	$record = geoip_record_by_name($realaddress);

	if ( $record['city'] == "" || $record['region'] == "" ) {
// 		echo "You are in: ". $record['country_name'] ."\n";;
		$location = $record['country_name'];
	} else {
		if ( isset($record['city']) && isset($record['region'])) {
			if ( $record['country_code'] != "US" ) {
// 				echo "You are in: ". $record['city'] .", ". $record['country_name'] ."\n";
				$location = $record['city'] .", ". $record['country_name'];
			} else {
// 				echo "You are in: ". $record['city'] .", ". $record['region'] ."\n";
				$location = $record['city'] .", ". $record['region'];
			}
		}
	}
} else {
	$location = "UNKNOWN";
}
//////////////////////////

//print "$realaddress\t$location\n";
//print "$location\n";
print "$location";
?>

