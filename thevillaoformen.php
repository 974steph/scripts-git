#!/usr/bin/env php
<?php

// MENTIAL NOTE TO SELF
// curl -sL "https://thevillaoformen.tumblr.com" | awk '/<figure class="post-content high-res"/,/<\/figure>/' | grep -m1 "img src" | sed 's/.*src="\(.*\)" alt.*/\1/'

$rawRSS = file_get_contents("http://thevillaoformen.tumblr.com/rss");

$slackEndPoint = "https://hooks.slack.com/services/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";

$xml_object = simplexml_load_string($rawRSS);

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

//	global $post;

	print_r($post);

	print "TITLE: $post->title\n";
	print "DATE: $post->date\n";
	print "TS: $post->ts\n";
	print "LINK: $post->link\n";
	print "DESC: $post->desc\n";
	print "TEXT: $post->text\n";
}

function doSlack($post) {

	global $slackEndPoint;


	print_r($post);

	$title = $post->title;
	$imgURL = $post->imgURL;

	print "TITLE: $title\n";
	print "URL: $imgURL\n";

	// Create a constant to store your Slack URL
	define('SLACK_WEBHOOK', $slackEndPoint);

	// Make your message

//	$payload = json_encode(array("text" => "$imgURL", "pretext" => "$title"), JSON_UNESCAPED_SLASHES);
	$payload = json_encode(array("text" => "$imgURL", "title" => "$title"), JSON_UNESCAPED_SLASHES);
//	$payload = json_encode(array("fields" => array("title" => "$title", "value" => "$imgURL")), JSON_UNESCAPED_SLASHES);

//	$depth = json_encode(array("title" => "$title", "value" => "$imgURL"), JSON_UNESCAPED_SLASHES);
//	$depth = str_replace('\"','"', json_encode(array("title" => "$title", "value" => "$imgURL"), JSON_UNESCAPED_SLASHES) );
//	print "DEPTH: $depth\n";
//	$payload = json_encode("fields: [$depth]", JSON_UNESCAPED_SLASHES);
//	$payload = json_encode("attachments: [$depth]", JSON_UNESCAPED_SLASHES);

	print "PAYLOAD:\n$payload\n";

//	exit();

//	$message = array('payload' => json_encode(array("fields" => array("title" => "$title", "value" => "$imgURL"))));
	$message = str_replace('\"','"', array("payload" => "$payload"));

	print_r($message);

	// Use curl to send your message
	$c = curl_init(SLACK_WEBHOOK);
	curl_setopt($c, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($c, CURLOPT_POST, true);
	curl_setopt($c, CURLOPT_POSTFIELDS, $message);
	curl_exec($c);
	curl_close($c);
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


	foreach( $DDoc->getElementsByTagName('img') as $node) {

		if ( ! is_array($node) ) {
			print "STRING: \"". $node->getAttribute('src') ."\"\n";

			$post->imgURL = $node->getAttribute('src');

			doSlack($post);

//			exit();
		}
	}

	if ( $y == $x ) {
		print "+++++++++ ($y == $x ) +++++++++\n";
		exit();
	} else {
		DumpStuff($post);
		print "+++++++++ ($y != $x ) +++++++++\n";
	}

	$y++;
}

?>
