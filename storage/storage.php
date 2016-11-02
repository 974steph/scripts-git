#!/usr/bin/env php
<?php

//https://www.sparefoot.com/search.html?searchType=storage-only&location_id=1447205&location=19341&latitude=40.045244&longitude=-75.638266&distance=15&zoom=&moveInDate=&sqft=&order=distance&page=1


//$rawPage = exec('curl -sL -X GET "https://www.sparefoot.com/search.html?moveInDate=&location=19341&order=distance" | grep "CONFIG.search" | sed "s/.* = //;s/\;$//"');

// EXTON
//$URL= "https://www.sparefoot.com/search.html?searchType=storage-only&location_id=1447205&location=19341&latitude=40.045244&longitude=-75.638266&distance=15&zoom=&moveInDate=&sqft=&order=distance&page=1";

// EAGLE
$URL = "https://www.sparefoot.com/search.html?searchType=storage-only&location_id=&location=Eagle,%20PA,%20United%20States&latitude=&longitude=&distance=&zoom=&moveInDate=&sqft=&order=distance&page=1";

//$rawPage = exec('curl -sL -X GET "https://www.sparefoot.com/search.html?searchType=storage-only&location_id=1447205&location=19341&latitude=40.045244&longitude=-75.638266&distance=15&zoom=&moveInDate=&sqft=&order=distance&page=1" | grep "CONFIG.search" | sed "s/.* = //;s/\;$//"');
$rawPage = exec("curl -sL -X GET \"$URL\" | grep \"CONFIG.search\" | sed \"s/.* = //;s/\;$//\"");

/*
$storageJSON = json_decode($rawPage);

//print_r($storageJSON->facilityCollection->collection);
//$len = count($storageJSON->facilityCollection->collection);
//print "LEN: $len\n";

foreach($storageJSON->facilityCollection->collection as $site) {
	print $site->name ." - ". $site->distance ." miles\n";
	print "\thttp://www.sparefoot.com". $site->url->facility ."\n";
	print $site-> ."\n";
}
*/


$storageJSON = json_decode($rawPage,true);

//print_r($storageJSON->facilityCollection->collection);
//$len = count($storageJSON->facilityCollection->collection);
//print "LEN: $len\n";


foreach($storageJSON['facilityCollection']['collection'] as $site) {
	print_r($site);
	exit();
	print $site['name'] ." - ". $site['distance'] ." miles\n";
	print "\thttp://www.sparefoot.com". $site['url']['facility'] ."\n";
//	print_r(array_keys($site['units'])) ."\n";
	print_r($site['units']);
	print "===========================\n\n";
}

?>
