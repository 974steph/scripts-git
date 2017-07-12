#!/usr/bin/env php
<?php

date_default_timezone_set('US/Eastern');

global $now,$nowPretty,$place,$lat,$lon,$weatherXML,$weatherCSV;

$now = time();
$nowPretty = date('Y-m-d H:i:s', $now);

$places = array(
	"Bend"=>array("lat"=>"44.0583","lon"=>"-121.314"),
	"Tucson"=>array("lat"=>"32.2217","lon"=>"-110.9265")
	);

function getWeather($place,$lat,$lon) {

	global $now,$nowPretty,$place,$lat,$lon,$weatherXML;

	print "place: $place\n";
	print "lat: $lat\n";
	print "lon: $lon\n";

	$weatherURL = "http://forecast.weather.gov/MapClick.php?lat=". $lat ."&lon=". $lon ."&unit=0&lg=english&FcstType=dwml";

//	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36

	$options = array(
		'http'=>array(
			'method'=>"GET",
			'header'=>"Accept-language: en\r\n" .
			"Cookie: foo=bar\r\n" .  // check function.stream-context-create on php.net
			"User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36\r\n"
		)
	);

	$context = stream_context_create($options);
	$weatherRaw = file_get_contents($weatherURL, false, $context);

	$weatherXML = new SimpleXMLElement($weatherRaw);
	unset($weatherRaw);
}


function buildArray($weatherXML) {

	global $now,$nowPretty,$place,$lat,$lon,$weatherXML,$weatherCSV;

	$weatherCSV = array();

	foreach ($weatherXML->data[1]->parameters as $k=>$v) {

		foreach ($v as $kk=>$vv) {

			$name = $kk;
			$type = trim(preg_replace('/\s/','',$vv->attributes()->type));
			$value = trim(preg_replace('/\s/','',$vv->value));

			if ( $value == "NA" ) { $value = 0; }

			if ( $name == "weather") {
				foreach ($vv as $key=>$value) {
					$deepValue = $value[0]['weather-summary'];
					if (strlen($deepValue) > 0 ) {
						$type = trim(preg_replace('/\s/','',$key));
						$value = trim(preg_replace('/\s/','',$deepValue));
						break;
					}
				}
			}

			if ( $name != "conditions-icon" ) {

				$weatherCSV["$type"] = "$value";
			}
		}
	}

	print_r($weatherCSV);
}


function makeCSV($weatherCSV) {

	global $now,$nowPretty,$place,$lat,$lon,$weatherXML,$weatherCSV;

/*
	print "now: $now\n";
	print "nowPretty: $nowPretty\n";
	print "apparent: ". $weatherCSV['apparent'] ."\n";
	print "relative: ". $weatherCSV['relative'] ."\n";
	print "barometer: ". $weatherCSV['barometer'] ."\n";
	print "sustained: ". $weatherCSV['sustained'] ."\n";
	print "gust: ". $weatherCSV['gust'] ."\n";
	print "wind: ". $weatherCSV['wind'] ."\n";
	print "weather-conditions: ". $weatherCSV['weather-conditions'] ."\n";
*/

	$stringCSV = "";
	$stringCSV .= "$now";
	$stringCSV .= ",". $nowPretty;
	$stringCSV .= ",". $weatherCSV['apparent'];
	$stringCSV .= ",". $weatherCSV['relative'];
	$stringCSV .= ",". $weatherCSV['barometer'];
	$stringCSV .= ",". $weatherCSV['sustained'];
	$stringCSV .= ",". $weatherCSV['gust'];
	$stringCSV .= ",". $weatherCSV['wind'];
	$stringCSV .= ",". $weatherCSV['weather-conditions'];

	print $stringCSV ."\n";
}


foreach ( $places as $place=>$location ) {

	$lat = $location['lat'];
	$lon = $location['lon'];

	getWeather($place,$lat,$lon);

	buildArray($weatherXML);

	makeCSV($weatherCSV);
	print "===========================\n";
}
?>
