<?php
///////////////////////////
date_default_timezone_set('UTC');

$weatherArray = array();

$winds = array(
	"N" => "north",
	"NNE" => "north",
	"NE" => "north east",
	"ENE" => "east",
	"E" => "east",
	"ESE" => "east",
	"SE" => "south east",
	"SSE" => "south",
	"S" => "south",
	"SSW" => "south",
	"SW" => "south west",
	"WSW" => "west",
	"W" => "west",
	"WNW" => "west",
	"NW" => "north west",
	"NNW" => "north"
);
//	"" => "",
///////////////////////////


if (count($_GET) > 0) {
//	print_r($_GET);

	foreach ($_GET as $k=>$v) {

		if ($k = "latlon") {
			$latlon = explode(',', trim($v));

			if (count($latlon) == 2) {

				if (isset($latlon[0])) { $lat = $latlon[0]; }
				if (isset($latlon[1])) { $lon = $latlon[1]; }
				$city = getStation($lat,$lon);

				$weatherArray = array(
					"location" => array(
						"city" => "$city",
						"latitude" => "$lat",
						"longitude" => "$lon"
					)
				);
//				print_r($weatherArray);
			} else {
				bail();
			}
		}
	}
} else {
	bail();
}


//http://api.wunderground.com/api/ae223e6da45800c2/geolookup/q/40.0722567,-75.5250655.json
//http://api.wunderground.com/api/ae223e6da45800c2/conditions/q/40.0722567,-75.5250655.json
//http://api.wunderground.com/api/ae223e6da45800c2/forecast/q/40.0722567,-75.5250655.json
//http://api.wunderground.com/api/ae223e6da45800c2/planner_MMDDMMDD/q/40.0722567,-75.5250655.json
//http://api.wunderground.com/api/ae223e6da45800c2/planner_10171018/q/42.0765086,-71.5423446.json
//http://api.wunderground.com/api/ae223e6da45800c2/forecast10day/q/42.0765086,-71.5423446.json

function bail() {
	http_response_code(404);
	exit();
}


///////////////////////////
// FIX WIND
//
function fixWind($str) {

	global $winds;

	$strArray = explode(' ',$str);
	$str = '';

	foreach ($strArray as $v) {
		if (array_key_exists($v, $winds)) {
			$str .= "$winds[$v] ";
		} else {
			$str .= "$v ";
		}
	}

//	print "STR: $str\n";

	return $str;
}
///////////////////////////


///////////////////////////
// FLUSH CURL
//
function flushCurl() {

	global $verbose;

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_USERAGENT,'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36');
//	curl_setopt($curl, CURLOPT_USERAGENT,'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.13) Gecko/20080311 Firefox/2.0.0.13');
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
// GET STATION NAME
//
function getStation($lat,$lon) {
	$station = doCURL($lat, $lon, "geolookup");
	$stationName = trim($station['location']['city']);

	return $stationName;
}
///////////////////////////


///////////////////////////
// GET WEATHER
//
function doCURL($lat, $lon, $action) {

	$curl = flushCurl();

	$url = "http://api.wunderground.com/api/ae223e6da45800c2/". $action ."/q/". $lat .",". $lon .".json";

	curl_setopt($curl, CURLOPT_URL, "$url");
	curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");

	$outputRAW = curl_exec($curl);
//	print $outputRAW;

	$outputJSON = json_decode($outputRAW, TRUE);
//	print_r($outputJSON);

	return $outputJSON;
}
///////////////////////////


///////////////////////////
// GET WEATHER
//
function getWeather($lat, $lon, $weatherArray) {

	$forecast = doCURL($lat, $lon, "forecast10day");

	$sdate = date('md');
	$edate = $sdate + 1;

	$purl = "planner_". $sdate ."". $sdate ."";
//	print "1: purl: $purl\n";
	$planner = doCurl($lat, $lon, $purl);

	$precipAvgToday = $planner['trip']['precip']['avg']['in'];
	$coRainToday = $planner['trip']['chance_of']['chanceofrainday']['percentage'];
	$coSnowToday = $planner['trip']['chance_of']['chanceofsnowonground']['percentage'];

	$purl = "planner_". $edate ."". $edate ."";
	$planner = doCurl($lat, $lon, $purl);
//	print "2: purl: $purl\n";

	$precipAvgTomorrow = $planner['trip']['precip']['avg']['in'];
	$coRainTomorrow = $planner['trip']['chance_of']['chanceofrainday']['percentage'];
	$coSnowTomorrow = $planner['trip']['chance_of']['chanceofsnowonground']['percentage'];

//	print "F: $f\n";

	$f = fixWind(preg_replace('/F. /', ' degrees. ', $forecast['forecast']['txt_forecast']['forecastday'][0]['fcttext']));
	$weatherArray['today'] = array(
		'day' => $forecast['forecast']['txt_forecast']['forecastday'][0]['title'],
		'forecast' => $f,
		'corain' => $coRainToday,
		'cosnow' => $coSnowToday,
		'precipavg' => $precipAvgToday
		);

	$f = fixWind(preg_replace('/F. /', ' degrees. ', $forecast['forecast']['txt_forecast']['forecastday'][1]['fcttext']));
	$weatherArray['tonight'] = array(
		'day' => $forecast['forecast']['txt_forecast']['forecastday'][1]['title'],
		'forecast' => $f
		);

	$f = fixWind(preg_replace('/F. /', ' degrees. ', $forecast['forecast']['txt_forecast']['forecastday'][2]['fcttext']));
	$weatherArray['tomorrow'] = array(
		'day' => $forecast['forecast']['txt_forecast']['forecastday'][2]['title'],
		'forecast' => $f,
		'corain' => $coRainTomorrow,
		'cosnow' => $coSnowTomorrow,
		'precipavg' => $precipAvgTomorrow
		);

//	print_r($weatherArray);

	return $weatherArray;
}
///////////////////////////


$fortune = strtolower(shell_exec('fortune chalkboard | head -n1'));

$weatherArray = getWeather($lat, $lon, $weatherArray);

//print_r($weatherArray);

print $weatherArray['today']['day'] ."'s forecast for ". $weatherArray['location']['city'] ." is ";
print $weatherArray['today']['forecast'] ."\n\n";
print "Tonight will be ". $weatherArray['tonight']['forecast'] ."\n\n";
print "Tomorrow might be ". $weatherArray['tomorrow']['forecast'] ."\n\n";
print "$fortune";
?>
