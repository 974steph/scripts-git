#!/usr/bin/env php
<?php

$rawRSS = file_get_contents("http://thevillaoformen.tumblr.com/rss");

$xml_object = simplexml_load_string($rawRSS);

class BlogPost {
	var $date;
	var $ts;
	var $link;
	var $title;
	var $text;
}

function DumpStuff() {

	global $post;

	print "TITLE: $post->title\n";
	print "DATE: $post->date\n";
	print "TS: $post->ts\n";
	print "LINK: $post->link\n";
	print "DESC: $post->desc\n";
//	print "TEXT: $post->text\n";
}

//print_r($xml_object->channel->item);
//exit();

$post = array();

$x = 2;
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



//	print_r($DDoc->firstChild->nextSibling);


	foreach( $DDoc->getElementsByTagName('img') as $node) {
//		$array[] = $node->nodeValue;
//		print "nodeValue: ". $node->nodeValue ."\n";

//		print "IS ARRAY: ". is_array($node) ."\n";

/*
		if ( is_array($node)) {
			print "ARRAY\n";
			print "ARRAY: \"". $node->nodeValue ."\"\n";
		} else {
*/
		if ( ! is_array($node) ) {
//			print "STRING\n";
//			print "STRING: \"". $node->tagName ."\"\n";
			print "STRING: \"". $node->getAttribute('src') ."\"\n";
//			print "STRING: ". $node ."\"". $node->nodeValue ."\"\n";
//			print "STRING: \"". $node->nodeValue ."\"\n";
//			print "STRING: \"". $node ."\"\n";
//			var_dump($node->attributes);

/*
			if ( $node->tagName === "img" ) {
				print_r($node->childNodes);
			}

			foreach($node as $next) {
				var_dump($next);
			}
*/
		}
	}

//		print_r($node);




	if ( $y == $x ) {
		print "+++++++++ ($y == $x ) +++++++++\n";
//		exit();
	} else {
		DumpStuff($post);
		print "+++++++++ ($y != $x ) +++++++++\n";
	}

	$y++;
}

//print_r($post);
exit();



foreach ( $xml_object->channel->item as $k=>$v ) {

	$description = $v->description;

/*
	$DDoc = new DOMDocument();
	$DDoc->loadHTML($description);
	$DDoc->normalizeDocument();

	foreach( $DDoc->getElementsByTagName('img') as $node) {
		$array[] = $node->nodeValue;
		print $node .": ". $node->nodeValue ."\n";
	}

	print_r($array);
*/
/*
	$DDoc = file_get_html($description);
	foreach ($DDoc as $line) {
		print "LINE: $line\n";
	}
*/


	$dom = new domDocument;

	$dom->loadHTML($description);

	$dom->preserveWhiteSpace = false;

//	$content = $dom->getElementsByTagname('<body>');

	$out = array();

//	var_dump($dom);
/*
//	foreach ($content as $item) {
	foreach ($dom as $item) {

		if (isArray($item)) {
			foreach ($item as $more) {
				print "MORE: ". $more->nodeValue ."\n";
				$out[] = $more->nodeValue;
			}
		} else {

			print "ITEM: ". $item->nodeValue ."\n";
			$out[] = $item->nodeValue;
		}
	}

    	var_dump($out);
*/


exit();

	$title = $v->title;
	$link = $v->link;
	$pubDate = $v->pubDate;
	$desc = preg_replace('/thevillaoformen:|\n/','',$DDoc->textContent);
//	print "DESC: ". $DDoc->textContent ."\n";
//	$blockQuote = $v->blockquote;

//	simplexml_load_string($rawRSS);



	print "TITLE: $title\n";
	print "DESC: $desc\n";
//	print "QUOTE: $blockQuote\n";
	print "LINK: $link\n";
	print "DESC: $description\n";
//	print_r($DDoc->childNodes);
	printvar($DDoc);
	print "---------\n";

	exit();

/*
	if ( preg_match('#\b(gif|jpg|jpeg)\b#', $description) ) {

		$strip = trim(preg_replace('@<img src=\"|\"/.*@', '', trim(preg_replace('@\r|\n@', '', $description))));

		print "strip: $strip\n";
		print "\t". $v->pubDate ."\n";
	}
*/
}
?>
