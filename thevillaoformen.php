#!/usr/bin/env php
<?php

$rawRSS = file_get_contents("http://thevillaoformen.tumblr.com/rss");

$xml_object = simplexml_load_string($rawRSS);

//print_r($xml_object->channel->item);
//exit();

foreach ( $xml_object->channel->item as $k=>$v ) {

	$description = $v->description;

	if ( preg_match('#\b(gif|jpg|jpeg)\b#', $description) ) {

		$strip = trim(preg_replace('@<img src=\"|\"/.*@', '', trim(preg_replace('@\r|\n@', '', $description))));

		print "strip: $strip\n";
		print "\t". $v->pubDate ."\n";
	}
}
?>
