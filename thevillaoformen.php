#!/usr/bin/env php
<?php
/*
$now = time();
print $now ."\n";
$nowPretty = date('Ymd_His', $now);
print $nowPretty ."\n";
exit();
*/

include 'secret_stuff.php';

$debug = False;
//$debug = True;

// MENTIAL NOTE TO SELF
// curl -sL "https://thevillaoformen.tumblr.com" | awk '/<figure class="post-content high-res"/,/<\/figure>/' | grep -m1 "img src" | sed 's/.*src="\(.*\)" alt.*/\1/'

/*
try {
	$rawRSS = file_get_contents("http://thevillaoformen.tumblr.com/rss");
} catch (Exception $e) {
	echo 'file_get_contents Caught exception: ',  $e->getMessage(), "\n";
	exit(1);
}
*/

$rssurl = "http://thevillaoformen.tumblr.com/rss";

$slackEndPoint = "https://hooks.slack.com/services/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";

$imageRepo = $myhome ."/Pictures/thevillaoformen";

$shasumsCSV = $imageRepo ."/shasums.csv";

class BlogPost {
	var $date;
	var $ts;
	var $link;
	var $title;
	var $text;
	var $desc;
	var $imgURL;
}


//function loadSHASums($shasumsCSV) {
function loadSHASums($shasumsCSV) {

	global $debug;

	$shasums = array();
	$csvCounter = 0;
	$file = fopen($shasumsCSV,"r");

	while (($data = fgetcsv($file)) !== FALSE) {
		$shasums[$csvCounter] = $data;
		$csvCounter++;
	}

	fclose($file);
	return $shasums;
}

//function verifySHA($remoteSHA, $fullImgPath) {
function verifySHA($remoteSHA) {

	global $debug, $shasumsCSV;

	$shasums = loadSHASums($shasumsCSV);

	$thisSHA = sha1_file($remoteSHA);

	if ($debug) { print "thisSHA: $thisSHA\n"; }

	$saveImage = True;

	foreach ($shasums as $k=>$v) {

//		print "K: $k || V: ". $v[0] ." -> ". $v[1] ."\n";

		if ($thisSHA == $v[0]) {
			if ($debug) { print "Skipping $thisSHA == ". $v[0] ." from ". $v[1] ."\n"; }
			$saveImage = False;
		}
	}

	if ($saveImage) {
		if ($debug) { print "$thisSHA is not a duplcate.  Saving...\n"; }
		fputcsv($shasumsCSV, array($thisSHA,$filename));
	}

	return $saveImage;
}

function getRawRss($rssurl) {

	global $debug;

	try {
		$rawRSS = file_get_contents("http://thevillaoformen.tumblr.com/rss");
		$xml_object = simplexml_load_string($rawRSS);
	} catch (Exception $e) {
		echo 'file_get_contents Caught exception: ',  $e->getMessage(), "\n";
		$xml_object = False;
	}

	return $xml_object;
}

function DumpStuff($post) {

	global $debug;

//	print_r($post);

	print "TITLE: $post->title\n";
	print "DATE: $post->date\n";
	print "TS: $post->ts\n";
	print "LINK: $post->link\n";
	print "DESC: $post->desc\n";
	print "TEXT: $post->text\n";
}


function doSlack($post) {

	global $debug, $slackEndPoint;

	if ($debug) { print_r($post); }

	$title = $post->title;
	$imgURL = $post->imgURL;
	$desc = $post->desc;

	if ($debug) {
		print "TITLE: $title\n";
		print "URL: $imgURL\n";
		print "DESC: $desc\n";
	}

	// Create a constant to store your Slack URL
	if ( ! defined('SLACK_WEBHOOK') ) {
		define('SLACK_WEBHOOK', $slackEndPoint);
	}

	// Make your message

	if ( strlen($desc) > 0 ) {
//		$payloadText = "$desc\n\n$imgURL";
		$payloadText = "$imgURL\n\n$desc";
	} else {
		$payloadText = "$imgURL";
	}

	$payload = json_encode(array("text" => "$payloadText", "title" => "$title"), JSON_UNESCAPED_SLASHES);

//	$message = array('payload' => json_encode(array("fields" => array("title" => "$title", "value" => "$imgURL"))));
	$message = str_replace('\"','"', array("payload" => "$payload"));

	if ($debug) {
		print "PAYLOAD:\n$payload\n";
		print_r($message);
	}

	// Use curl to send your message
	$c = curl_init(SLACK_WEBHOOK);
	curl_setopt($c, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($c, CURLOPT_POST, true);
	curl_setopt($c, CURLOPT_POSTFIELDS, $message);
	curl_exec($c);
//	print "\nSLACK\n\n";
	curl_close($c);
}

function getImage($post) {

	global $debug, $imageRepo;

	$info = new SplFileInfo($post->imgURL);

//	$filename = $post->title ."_". $post->ts .".". $info->getExtension();
	$filename = date('Ymd_His', $post->ts) .".". $info->getExtension();

	$fullImgPath = $imageRepo."/".$filename;

	if ($debug) { print "fullImgPath: $fullImgPath\n"; }

	if ( ! is_file($fullImgPath) ) {

		if ($debug) { print "I don't have \"$filename\".  Fetching...\n"; }

		file_put_contents($fullImgPath, file_get_contents($post->imgURL));

		$gotImage = True;
	} else {
		$gotImage = False;
	}

	return array($gotImage,$fullImgPath);
}


$xml_object = getRawRss($rssurl);

if ( ! $xml_object ) {
	echo "xml_object: \""+ $xml_object +"\"\n";
	exit(1);
}

$post = array();

$x = 1;
$y = 0;

foreach ($xml_object->channel->item as $item) {

//	print_r($item);

	$post = new BlogPost();
	$post->date  = (string) $item->pubDate;
	$post->ts    = strtotime($item->pubDate);
	$post->link  = (string) $item->link;
//	$post->title = (string) $item->title;
	$post->title = str_replace(array("\n", "\t", "\r"), ' ', $item->title);
//	$post->text  = (string) $item->description;
	$post->text  = str_replace(array("\n", "\t", "\r"), ' ', $item->description);

//	print_r($post);

	libxml_use_internal_errors(true);
	$DDoc = new DOMDocument();
	$DDoc->loadHTML($post->text);
	$DDoc->normalizeDocument();
	libxml_use_internal_errors(false);

	$replaceThese = array("thevillaoformen:","\n");

	$post->desc = str_replace($replaceThese,'',$DDoc->documentElement->textContent);

//	print "DESC: ". $post->desc ."\n";

	foreach( $DDoc->getElementsByTagName('img') as $node) {

		$saveImage = False;
		$gotImage = False;

		if ( ! is_array($node) ) {
			if ($debug) { print "STRING: \"". $node->getAttribute('src') ."\"\n"; }

			$post->imgURL = $node->getAttribute('src');

			$thisURL = $post->imgURL;

			$saveImage = verifySHA($thisURL);

			if ($saveImage) {

				$fromGetImage = getImage($post);

				print_r($fromGetImage);

				$gotImage = $fromGetImage[0];
				$fullImgPath = $fromGetImage[1];
			}

			if ($gotImage) {

				if ($debug) { print "saveImage IF : $saveImage || $fullImgPath is a new image.  Saving...\n"; }

				doSlack($post);

				unset ($haveImage);
			}
		}
	}

	if ( $y == $x ) {
		if ($debug) {
			DumpStuff($post);
			print "+++++++++ ($y == $x ) +++++++++\n";
		}
		exit();
	} else {
		if ($debug) {
			DumpStuff($post);
			print "+++++++++ ($y != $x ) +++++++++\n";
		}
	}

	$y++;
}
?>
