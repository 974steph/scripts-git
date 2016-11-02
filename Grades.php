#!/usr/bin/php
<?php

include $_SERVER['HOME'] ."/Sources/scripts-git/secret_stuff.php";

date_default_timezone_set('America/New_York');
$now = time();
$now = "1416546000";
$nowPretty = date('Y-m-d g:i:sa', $now);
$nowGradesDate = date('Y-m-d', $now);
$nowGradeFileName = date('dMY', $now);
$rawDIR = "$myhome/temp/Grades";
$nowGradeFile = "$rawDIR/$nowGradeFileName";
$gpath = "$myhome/Nathan/Grades";
$gradesArray = array();
$csvGrades = "$nowGradesDate,";
$csvClasses = "10th Grade,";
$todayRecorded = "";

function CheckMail() {

	echo "===========================\n";
	echo " CHECK MAIL\n";
	echo "===========================\n";

	global $rawDIR, $nowGradeFile, $now;

// 	$outFile=fopen($nowGradeFile,"w");

	$hostname = '{imap.gmail.com:993/imap/ssl}INBOX';
	$username = "$emailMine";
	$password = 'WRONG_PASS';

	/* try to connect */
	$inbox = imap_open($hostname,$username,$password) or die('Cannot connect to Gmail: ' . imap_last_error());

	/* grab emails */
// 	$emails = imap_search($inbox, 'ALL', 'noreply@wcasd.net');
	$emails = imap_search($inbox, 'FROM noreply@wcasd.net');

	/* if emails are returned, cycle through each... */
	if( $emails ) {

		/* begin output var */
		$output = '';

		/* put the newest emails on top */
// 		rsort($emails);

		/* for every email... */
		foreach($emails as $email_number) {

			/* get information specific to this email */
			$overview = imap_fetch_overview($inbox,$email_number,0);

// 			if ( $overview[0]->from == "noreply@wcasd.net" && $overview[0]->seen == 0 ) {
// 			if ( $overview[0]->from == "noreply@wcasd.net" ) {
				$output.= "Number: $email_number\n";
				$output.= "From: ". $overview[0]->from ."\n";
				$output.= "Subject: ". $overview[0]->subject."\n";
				$output.= "Seen: ". $overview[0]->seen ."\n";
				$output.= "Date: ". $overview[0]->date ."\n";

				$message = imap_fetchbody($inbox,$email_number,1);
// 				$message = imap_body($inbox, $email_number, 'FT_PEEK');

// 				echo "MESSAGE: ". $message;

				$outFile=fopen($nowGradeFile,"w");
				fwrite($outFile,$message);
				fclose($outFile);

				if ( file_exists($nowGradeFile) ) {
					echo "Wrote $nowGradeFile.\n";
					}
				else {
					echo "Failed to write $nowGradeFile.\n";
					}


// 				imap_setflag_full($inbox, $email_number, 'unseen');

// 				imap_mail_move($inbox, "$email_number", 'School');

// 				break;
// 			}
		}
	} 

	/* close the connection */
	imap_close($inbox);

	echo "$output\n";

	exit();
}


function GuessSchoolYear() {

	echo "===========================\n";
	echo " GUESS SCHOOL YEAR\n";
	echo "===========================\n";

	global $now, $gpath, $gfile;

	$nowYear = date('Y', $now);
	$nowMonth = date('m', $now);

	if ( $nowMonth > 07 && $nowMonth < 13 ) {
		$schoolYearStart = $nowYear;
		$schoolYearEnd = ($schoolYearStart + 1);
	}
	elseif ( $nowMonth < 07 ) {
		$schoolYearEnd = $nowYear;
		$schoolYearStart = ($schoolYearEnd - 1);
	}

	echo "schoolYearStart: \"$schoolYearStart\"\n";
	echo "schoolYearEnd: \"$schoolYearEnd\"\n";

	if ( (! $nowMonth == 07) || (! $nowMonth == 08) ) {

		echo "nowMonth: \"$nowMonth\"\n";
		echo "nowYear: \"$nowYear\"\n";

// 		switch ($nowYear):
// 			case 2012:
			if ($nowYear == 2012) {
				$sYearFile = $schoolYearStart ."-". $schoolYearEnd ."_8th";
				$sYearHeader = "8th Grade";
// 				break;
			}
			elseif ($nowYear == 2013) {
// 			case 2013:
				$sYearFile = $schoolYearStart ."-". $schoolYearEnd ."_9th";
				$sYearHeader = "9th Grade";
// 				break;
			}
			elseif ($nowYear == 2014) {
// 			case 2014:
				$sYearFile = $schoolYearStart ."-". $schoolYearEnd ."_10th";
				$sYearHeader = "10th Grade";
// 				break;
			}
			elseif ($nowYear == 2015) {
// 			case 2015:
				$sYearFile = $schoolYearStart ."-". $schoolYearEnd ."_11th";
				$sYearHeader = "11th Grade";
// 				break;
			}
			elseif ($nowYear == 2016) {
// 			case 2016:
				$sYearFile = $schoolYearStart ."-". $schoolYearEnd ."_12th";
				$sYearHeader = "12th Grade";
			}
			else {
// 			default:
				echo "\nUNKNOWN GRADE AND YEAR\n";
				die;
			}
// 		endswitch;


// 		GFILE="${GPATH}/Grades_${SYEARFILE}.csv"
		$gfile = $gpath ."/Grades_". $sYearFile .".csv";

		echo "sYearFile: $sYearFile\n";
		echo "sYearHeader: $sYearHeader\n";
		echo "gfile: $gfile\n";
	}
	else {
		echo "SUMMER\n";
		die;
	}

}


function LoadYearCSV() {

	echo "===========================\n";
	echo " LOAD YEAR CSV\n";
	echo "===========================\n";

	global $gradesArray, $now, $csvGrades, $csvClasses, $nowGradesDate, $rawDIR, $gpath, $gfile, $sYearFile, $gfileCSV, $todayRecorded, $gfileCSVLength;

	echo "gfileCSV: $gfileCSV\n";
	echo "gfile: $gfile\n";

	$gfileCSV = fopen($gfile,"rb") or exit("Unable to open $nowGradeFile!");;

	$r=0;

	while (($result = fgetcsv($gfileCSV, 1000, ",")) !== FALSE) {
		$sYearFileArray[$r] = $result;
// 		echo "result[0]: $result[0]\n";

		if ( $result[0] == $nowGradesDate ) {


//FIXME
			$todayRecorded = "TRUE";
// 			$todayRecorded = "FALSE";




// 			echo "todayRecorded: $todayRecorded: $result[0] - $nowGradesDate\n";
		}
		else {
			$todayRecorded = "FALSE";
// 			echo "todayRecorded: $todayRecorded: $result[0] - $nowGradesDate\n";
		}

		$r++;
	}

	unset($r);

	fclose($gfileCSV);

	$gfileCSVLength = count($sYearFileArray);
// 	echo "sYearFileArray: $sYearFileArray\n";
	echo "gfileCSVLength: $gfileCSVLength\n";
	echo "todayRecorded: $todayRecorded\n";
}


function ReadGrades() {

	echo "===========================\n";
	echo " READ GRADES\n";
	echo "===========================\n";

	global $rawDIR, $nowGradeFile, $now, $gradesArray;

	$outFile = fopen($nowGradeFile,"rb") or exit("Unable to open $nowGradeFile!");;
// 	$outFileSize = filesize($nowGradeFile);
// 	echo "\toutFileSize: $outFileSize\n";
// 	fread($outFile, $outFileSize);

	$r = 0;

	while ( ! feof($outFile) ) {
// 	while ( ($line = fgets($outFile)) !== false) {

		$line = trim(fgets($outFile));

		if ( preg_match('/PERIOD/',$line) || preg_match('/Current Grade/',$line) && ! $line == "" ) {

			if ( preg_match('/PERIOD/',$line) ) {
				$linePeriod = $line;
				}

			if ( preg_match('/Current Grade/',$line) ) {
// 			if ( ! isset($lineGrade) ) {
				$lineGrade = $line;
				}


			if ( isset($linePeriod) && isset($lineGrade) ) {


				$lineFull = trim($linePeriod ." ". $lineGrade);

// 				echo "\n";
// 				echo "$lineFull\n";

				/////////
				// Class Name
				$line1 = preg_replace('/PERIOD*:/', '', $linePeriod);

				$className = trim(preg_replace('/\(.*/', '', substr(strstr($line1, ': '), 2)));
// 				echo "className: $className\n";

				unset($line1);
				/////////

				/////////
				// Class Grade
// 				echo "$lineGrade\n";

// 				$lineGradeArray = explode(':', $lineGrade);
// 				print_r($lineGradeArray);

				$line1 = substr(strstr($lineGrade, ': '), 2, 3);
				$line2 = preg_replace('/[a-zA-Z ]/', '', substr($line1,2, 3));

				if ( $line2 == "" ) {
					$classGrade = trim(substr(strstr($lineGrade, ': '), 2, 2));


					if ( $classGrade == "--" ) { $classGrade = ""; };


					}
				else {
					$classGrade = trim(substr(strstr($lineGrade, ': '), 2, 3));
					}

// 				echo $classGrade;

				if ( ! preg_match('~\b(homeroom|lunch|study hall)\b~i',$className) ) {


					$c = 0;
					$classExplode = explode(' ', $className);
					$classExplodeLength = count($classExplode);

					$className = "";

					while ($c < ($classExplodeLength - 1)) {

						$className .= "$classExplode[$c]";

						if ($c < ($classExplodeLength - 2)) { $className .= " "; }

						$c++;
					}

					unset($c);

					$gradesArray[$r]['class'] = trim($className);
					$gradesArray[$r]['grade'] = $classGrade;

					echo "className: \"$className\"\n";
					echo "classGrade: \"$classGrade\"\n";

					unset($line1);
					unset($line2);
					/////////

					unset($linePeriod);
					unset($lineGrade);
					$r++;
				}
			}
		}
	}

	unset($r);

	fclose($outFile);
}

function DumpGrades() {

	echo "===========================\n";
	echo " DUMP GRADES\n";
	echo "===========================\n";

	global $gradesArray, $now, $csvGrades, $csvClasses, $nowGradesDate, $gfile, $todayRecorded, $gfileCSVLength;

	echo "gfileCSVLength: $gfileCSVLength\n";
	echo "todayRecorded: $todayRecorded\n";

	$gradesArrayLength = count($gradesArray);
	echo "gradesArrayLength: $gradesArrayLength\n";


// 	print_r($gradesArray);
// 	exit();


	$l = 0;

	while( $l < $gradesArrayLength ) {

		$class = trim($gradesArray[$l]['class']);
		$grade = trim($gradesArray[$l]['grade']);

		echo $class .": ". $grade ."\n";

		$csvClasses .= $class;
		$csvGrades .= $grade;

		if ( ($l + 1) != $gradesArrayLength ) { $csvClasses .= ","; }
		if ( ($l + 1) != $gradesArrayLength ) { $csvGrades .= ","; }

		$l++;
	}

	unset ($l);

	echo "csvClasses: $csvClasses\n";
	echo "csvGrades: $csvGrades\n";
	echo "gfile: $gfile\n";


	if ( $todayRecorded == "FALSE" ) {
		echo "Recording $nowGradesDate: $todayRecorded\n";
		$handle = fopen($gfile, "a");
		fwrite($handle,$csvGrades);
		fclose($handle);
		}
	else {
		echo "$nowGradesDate already recorded: $todayRecorded\n";
		exit;
		}
}

function PlotChart() {
	echo "===========================\n";
	echo " PLOT CHART\n";
	echo "===========================\n";

	global $gradesArray, $sYearFileArray, $now, $csvGrades, $csvClasses, $nowGradesDate, $rawDIR, $gpath, $gfile, $sYearFile;

	echo "gfile: $gfile\n";
	echo "gpath: $gpath\n";

	$chartFile = $gpath ."/". $sYearFile .".csv";


	$chartDIR = $gpath ."/Chart";
	echo "chartFile: $chartFile\n";

	if ( ! file_exists($chartDIR) ) {
		mkdir($chartDIR, 0644);
	}

	$chartValues = $chartDIR ."/plot.grades";
	$chartNames = $chartDIR ."/plot.names";
	$chartScript = $chartDIR ."/plot.script";
	$chartPlotName = $nowGradesDate ."_plot.png";

	echo "chartValues: $chartValues\n";
	echo "chartNames: $chartNames\n";
	echo "chartScript: $chartScript\n";
	echo "chartPlotName: $chartPlotName\n";

	$gfileCSV = fopen($gfile, "r");
	$csvGrades = array();
	$first_line = true;
	$y = 0;


	while ( ($csvData = fgetcsv($gfileCSV, 1000, ",")) !== FALSE ) {

		if (empty($csvData[0]) ) {
			// Skip blank lines...
			continue;
			}
		else {

			if ( $first_line == true ) {
				$data_length = count($csvData);
				$x = 0;
				$first_line = false;

				while ( $x < $data_length ) {

					$headerRow[$x] = $csvData[$x];
					$x++;
				}
			}
			else {
				$x = 0;
				while ( $x < $data_length ) {


				//FIXME
				// Need to account for grade for todayu being empty and look at the previous day


					$csvGrades[$y][$x] = $csvData[$x];
					$x++;
				}
				$y++;
			}
		}
	}

	unset($x);
	unset($y);

	echo "HEADER ROW:\n";
	print_r($headerRow);

	echo "BODY DATA: ". count($csvGrades) ." rows\n";

// 	print_r($csvGrades);
// 	exit(0);


	$xStartDate = $csvGrades[0][0];
	$xEndDate = $csvGrades[(count($csvGrades) - 1)][0];


	echo "xStartDate: $xStartDate\n";
	echo "xEndDate: $xEndDate\n";


	$chartScriptHandle = fopen($chartScript,"w");

	$chartScriptString = "set output '$chartDIR/$chartPlotName'\n";
	$chartScriptString .= "set datafile missing '0'\n";
	$chartScriptString .= "set term pngcairo size 360,600\n";
	$chartScriptString .= "set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb\"#FFFFFF\" behind\n";
	$chartScriptString .= "set grid\n";
	$chartScriptString .= "set lmargin 4.5\n";
	$chartScriptString .= "set rmargin 1\n";
	$chartScriptString .= "set tmargin 0.5\n";
	$chartScriptString .= "set bmargin 2\n";

	$chartScriptString .= "set key right bottom box\n";
	$chartScriptString .= "set key font \",8\"\n";
	$chartScriptString .= "set key width 0\n";
	$chartScriptString .= "set key spacing 0.8\n";

	$chartScriptString .= "set ylabel offset 4,0 \"Percent\"\n";
	$chartScriptString .= "set ylabel font \",9\"\n";

	$chartScriptString .= "set xlabel \"\"\n";
	$chartScriptString .= "set xdata time\n";
	$chartScriptString .= "set timefmt \"%Y-%m-%d\"\n";
	$chartScriptString .= "set xrange [\"$xStartDate\":\"$xEndDate\"]\n";
	$chartScriptString .= "set format x \"%b %d\"\n";

	$chartScriptString .= "set xtics rotate by 90 offset 0,-1.3\n";
	$chartScriptString .= "set xtics font \",7\"\n";
	$chartScriptString .= "set mxtics 0\n";

	$chartScriptString .= "set ytics offset 0.5,0\n";
	$chartScriptString .= "set ytics font \",7\"\n";
	$chartScriptString .= "set yrange [30:100]\n";
	$chartScriptString .= "set mytics 10\n";

	$chartScriptString .= "plot ";

	$u = 2;
	$x = 1;
	$headerRowLength = ( count($headerRow) - 1 );
	$eos = ", ";

	while ( $x <= $headerRowLength ) {

		$title = $headerRow[$x];

		echo "Title: $title\n";

		if ( $x == $headerRowLength ) { $eol = "\n"; }

		$chartScriptString .= "\"$chartValues\" using 1:$u title '$title' smooth bezier lw 2$eos";
		$x++;
		$u++;
	}

	unset($u);
	unset($x);
	unset($eos);

// 	echo "\n=========\n$chartScriptString\n=========\n";

	fwrite($chartScriptHandle, $chartScriptString);
	fclose($chartScriptHandle);
	fclose($gfileCSV);

	print_r($csvGrades);

	shell_exec("/usr/bin/gnuplot $chartScript");
}


function BuildHTML() {

	echo "===========================\n";
	echo " BUILD HTML\n";
	echo "===========================\n";



}

echo "\n---------\n";
echo "nowPretty: $nowPretty\n";
echo "nowGradeFileName: $nowGradeFileName\n";
echo "rawDIR: $rawDIR\n";
echo "nowGradeFile: $nowGradeFile\n";
echo "---------\n";

// CheckMail();
// echo "\n";

GuessSchoolYear();
echo "\n";

LoadYearCSV();
echo "\n";

ReadGrades();
echo "\n";

DumpGrades();
echo "\n";

PlotChart();
echo "\n";

?>
