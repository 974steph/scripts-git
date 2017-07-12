#!/usr/bin/env php
<?php

include $_SERVER['HOME'] ."/Sources/scripts-git/secret_stuff.php";

date_default_timezone_set('America/New_York');

/* connect to gmail */
$hostname = '{imap.gmail.com:993/imap/ssl}INBOX';
$username = $emailMine;
$password = $googlePasswd;


$filename = date('dMY', time());
$path = "$myhome/temp/Grades/";

if ( ! file_exists($path ."". $filename ."") ) {
//	echo "$filename NOT in $path\n";
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

			if ( $overview[0]->from == "noreply@wcasd.net" && $overview[0]->seen == 0 ) {
// 			if ( $overview[0]->from == "noreply@wcasd.net" ) {
// 				$output.= "". $email_number ." - ";
// 				$output.= "". $overview[0]->from .": ";
// 				$output.= "". $overview[0]->subject.": ";
// 				$output.= "". $overview[0]->seen ."\n";
// 				$output.= "". $overview[0]->date ."\n";

				$message = imap_fetchbody($inbox,$email_number,1);
// 				echo $output;
// 				echo $message;

				date_default_timezone_set("America/New_York");
				$date = date_create($overview[0]->date);

				$filename = date_format($date, 'dMY');
//				$path = "$myhome/temp/Grades/";

// 				$f = fopen("$myhome/file.txt", "w");
				$f = fopen($path ."". $filename ."", "w");
				fwrite($f, "". $message ."");
				fclose($f);

// 				10Dec2013

 				imap_mail_move($inbox, "$email_number", 'School');


				break;
			}
		}
	}

	/* close the connection */
	imap_close($inbox);
}
//else {
//	echo "$filename IS in $path\n";
//	exit(0);
//}
?>
