#!/usr/bin/php
<?php

$debug = "yes";

include $_SERVER['HOME'] ."/Sources/scripts-git/secret_stuff.php";

date_default_timezone_set('America/New_York');


/* connect to gmail */
$hostname = '{imap.gmail.com:993/imap/ssl}INBOX';
$username = "$emailMine";
$password = "$googlePasswd";;


$baseDir = "$myhome/wc";


//if ( ! file_exists($baseDir ."". $filename ."") ) {
//	echo "$filename NOT in $baseDir\n";
//	exit(1);

	/* try to connect */
	$inbox = imap_open($hostname,$username,$password) or die('Cannot connect to Gmail: ' . imap_last_error());

	/* grab emails */
	$emails = imap_search($inbox,'ALL');

	/* if emails are returned, cycle through each... */
	if($emails) {

		/* begin output var */
		$output = '';

		/* put the newest emails on top */
// 		rsort($emails);

		/* for every email... */
		foreach($emails as $email_number) {

			/* get information specific to this email */
			$overview = imap_fetch_overview($inbox,$email_number,0);

//			var_dump($overview);

//			if ( $overview[0]->from == "noreply@blizzard.com" && $overview[0]->seen == 0 ) {
			if ( preg_match("/noreply@blizzard.com/", $overview[0]->from) ) {
				$output.= "". $email_number ." - ";
				$output.= "". $overview[0]->from .": ";
				$output.= "". $overview[0]->subject.": ";
				$output.= "". $overview[0]->seen ."\n";
				$output.= "". $overview[0]->date ."\n";


				if ( isset($debug) ) {
					echo "=========\nSTRUCTURE\n";
					$structure = imap_fetchstructure($inbox,$email_number);
					var_dump($structure);
					echo "=========\n";
				}


				/* Strip HTML and clean up email */
				$message = quoted_printable_decode(imap_fetchbody($inbox,$email_number,1));
				$messageStripped = strip_tags(tidy_parse_string(quoted_printable_decode($message)));
				$messageStripped = preg_replace("/(^[\r\n]*|[\r\n]+)[\s\t]*[\r\n]+/", "\n", trim($messageStripped));


				$date = strtotime($overview[0]->date);
 				$filename = "". date('Y-m-d', $date) ."_PlayTimeReport.txt";


				if ( isset ($debug) ) {
					echo "\n=========\nmessageStripped\n";
					echo "$messageStripped\n";
					echo "\n=========\n";

					echo "\n=========\nDates\n";
					echo "DATES: ". $overview[0]->date ." = ". date('Y-m-d', $date) ."\n";
					echo "FILENAME: $filename\n";
					echo "\n=========\n";
				}


				if ( file_exists($baseDir ."". $filename ."") ) {
					echo "\n\n$baseDir/$filename exists.\n\n";
				}


				$f = fopen($baseDir ."/". $filename ."", "w");
// 				fwrite($f, "". preg_replace("/(^[\r\n]*|[\r\n]+)[\s\t]*[\r\n]+/", "\n", trim($messageStripped)) ."");
				fwrite($f, "". $messageStripped ."");
				fclose($f);


 				imap_mail_move($inbox, "$email_number", "$wcTarget");


				// COMMENT OUT TO LOOP
				break;
			}
		}
	}

	/* close the connection */
	imap_close($inbox);
// }
//else {
//	echo "$filename IS in $baseDir\n";
//	exit(0);
//}
?>
