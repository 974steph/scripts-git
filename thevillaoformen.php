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

// MENTIAL NOTE TO SELF
// curl -sL "https://thevillaoformen.tumblr.com" | awk '/<figure class="post-content high-res"/,/<\/figure>/' | grep -m1 "img src" | sed 's/.*src="\(.*\)" alt.*/\1/'

$rawRSS = file_get_contents("http://thevillaoformen.tumblr.com/rss");

$slackEndPoint = "https://hooks.slack.com/services/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";

$xml_object = simplexml_load_string($rawRSS);


$imageRepo = $myhome ."/Pictures/thevillaoformen";


class BlogPost {
	var $date;
	var $ts;
	var $link;
	var $title;
	var $text;
	var $desc;
	var $imgURL;
}

function DumpStuff($post) {

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
		file_put_contents($fullImgPath, file_get_contents($post->imgURL));
		$haveImage = False;
	} else {
		print "Already have: ". $fullImgPath ."\n";
		$haveImage = True;
	}

	return $haveImage;
}


$post = array();

$x = 1;
$y = 0;

foreach ($xml_object->channel->item as $item) {
	$post = new BlogPost();
	$post->date  = (string) $item->pubDate;
	$post->ts    = strtotime($item->pubDate);
	$post->link  = (string) $item->link;
	$post->title = (string) $item->title;
	$post->text  = (string) $item->description;

	$DDoc = new DOMDocument();
	$DDoc->loadHTML($post->text);
	$DDoc->normalizeDocument();

	$replaceThese = array("thevillaoformen:","\n");

	$post->desc = str_replace($replaceThese,'',$DDoc->documentElement->textContent);

//	print "DESC: ". $post->desc ."\n";

	foreach( $DDoc->getElementsByTagName('img') as $node) {

		if ( ! is_array($node) ) {
			if ($debug) { print "STRING: \"". $node->getAttribute('src') ."\"\n"; }

			$post->imgURL = $node->getAttribute('src');

			$haveImage = getImage($post);

			if ($haveImage) {
				if ($debug) { print "haveImage IF : $haveImage\n"; }
			} else {
				if ($debug) { print "haveImage ELSE: $haveImage\n"; }

				doSlack($post);

				unset ($haveImage);
			}
		}
	}

	if ( $y == $x ) {
		if ($debug) { print "+++++++++ ($y == $x ) +++++++++\n"; }
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
