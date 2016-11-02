#!/usr/bin/php
<?php

$region ="us";
$realm = "Dawnbringer";
$guild = "Legends%20of%20Dawnbringer";
$chars = array("Fleagus","Flonase","Cashus","Lofar","Xifaxan");
// $chars = array("Fleagus");

// http://us.battle.net/api/wow/guild/Dawnbringer/Legends%20of%20Dawnbringer?fields=members,achievements

// http://render-api-us.worldofwarcraft.com/static-render/us/
// 	madoran/202/163579850-avatar.jpg

// http://nitschinger.at/Handling-JSON-like-a-boss-in-PHP

?>
<html>
<head>
<title>My Character Stuff</title>
</head>
<body>

<?php


foreach ( $chars as $char ) {

?>
<table width="50%" border="1">
	<tr>
		<td colspan="3" align="center" bgcolor="black"><font color="white"><?php print $char ?></font></td>
	</tr>

	<tr>
		<td>Icon</td>
		<td>iLvl</td>
		<td>Name</td>
	</tr>
<?php

//	print "\n$char\n\n";

	@$charRAW = file_get_contents("http://us.battle.net/api/wow/character/Dawnbringer/$char?fields=items");
	$charJSON = json_decode($charRAW, true);

	$rows = array();
	$itot = 0;

//	print_r($charJSON);

	foreach ( $charJSON['items'] as $i => $e) {

		if ( is_array($e) ) {

			if ( ! ($i == 'shirt' || $i == 'tabard') ) {
				$rows[$i]['name'] = $e['name'];
				$rows[$i]['itemLevel'] = $e['itemLevel'];
				$rows[$i]['icon'] = $e['icon'];
				$rows[$i]['id'] = $e['id'];

				$itot = ($itot + $e['itemLevel']);
			}
		}
	}



// 	$rowCount = (count($rows) - 1);
	$rowCount = count($rows);

	$iavg = floor($itot / $rowCount);

/*
	print "itot: $itot\n";
	print "rowCount: $rowCount\n";
	print "iavg: $iavg\n\n";
*/
// 	print_r($rows);


	foreach ($rows as $key => $subkeys) {

		$item = $key;

		$name = $subkeys['name'];
		$icon = $subkeys['icon'];
		$id = $subkeys['id'];
		$ilevel = $subkeys['itemLevel'];

/*
		print $item ." - ". $name .": ". $ilevel ."\n";
		print "\tid: http://us.battle.net/wow/en/item/". $id ."\n";
		print "\ticon: http://us.media.blizzard.com/wow/icons/56/". $icon .".jpg\n";
*/
?>

	<tr>
		<td><img src="http://us.media.blizzard.com/wow/icons/56/<?php print $icon ?>.jpg"></td>
		<!-- td><img src="http://us.media.blizzard.com/wow/icons/18/<?php print $icon ?>.jpg"></td -->
		<td><?php print $ilevel ?></td>
		<td><a href="http://us.battle.net/wow/en/item/<?php print $id ?>" target="_blank"><?php print $name ?></a></td>
	</tr>
<?php

	}

//	print "=========\n";
?>
</table>
<br><br>
<?php
}

?>
</html>
<?php

exit(0);




$ranks = array(
	'Officer', // 0
	'Officer', // 1
	'Officer Alt', // 2
	'Raider', // 3
	'Alt', // 4
	'Trial', // 5
	'Social' // 6
);



@$json = file_get_contents("http://$region.battle.net/api/wow/guild/$realm/$guild?fields=members,achievements");

if($json == false) {
	throw new Exception("Failed To load infomation.");
}

// print_r($json);

$decode = json_decode($json, true);
//$rows = $decode['members'];
// print_r($decode);
// exit(0);

$rows=array();

foreach ($decode['members'] as $i => $e) {
	$rows[$i]['rank'] = $e['rank'];
	$rows[$i]['name'] = $e['character']['name'];
	$rows[$i]['class'] = $e['character']['class'];
	$rows[$i]['race'] = $e['character']['race'];
	$rows[$i]['level'] = $e['character']['level'];
	$rows[$i]['gender'] = $e['character']['gender'];
}


$s = (isset($_GET['s']) ? $_GET['s'] : '');
$u = (isset($_GET['u']) ? $_GET['u'] : '0');


if ($s != '') {
sksort($rows,$s,$u);
}
else {
sksort($rows,'rank',true);
}


//Guild Roster Table Headers
echo " <div width='600px' align#'center'>";
echo '
<div align="center" id="roster" class="roster" style="float: none;">
<table class="warcraft sortable" border="3" cellspacing="0" cellpadding="0" align="center">
<tr>
<th width="80px" align="center" valign="top" ><strong>Race</strong></a></th>
<th width="140px" align="center" valign="top" ><strong>Name</strong></a></th>
<th width="80px" align="center" valign="top" ><strong>Level</strong></a></th>
<th width="140px" align="center" valign="top" ><strong>Rank</strong></a></th>
</tr>';


//Character Arrays
foreach($rows as $p) {
	$mrank = $p['rank'];
	$mname = $p['name'];
	$mclass = $p['class'];
	$mrace = $p['race'];
	$mlevel = $p['level'];
	$mgender = $p['gender'];

	if ($mrank == 2 || $mrank == 4 || $mrank == 6 || $mrank == 8) {
		continue;
	}

	//Table of Guild Members
	echo "
	<tr>
	<td align='center'><strong><img style=\"padding-left: 5px;\" src=\"race/$mrace-$mgender.gif\"></img><img style=\"padding-left: 5px;\" src=\"class/$mclass.gif\"></img></strong></td>
	<td class='class_$mclass' width=\"140px\" align=\"center\" valign=\"top\" ><strong>$mname</strong></td>
	<td width=\"80px\" align=\"center\" valign=\"top\" ><strong>$mlevel</strong></td>
	<td sorttable_customkey='$mrank' width=\"140px\" align=\"center\" valign=\"top\" ><strong>$ranks[$mrank]</strong></td>
	</tr>
	";
}


echo " </table></div>";


function sksort(&$array, $subkey="id", $sort_ascending=false) {
	if (count($array))
		$temp_array[key($array)] = array_shift($array);


		foreach($array as $key => $val) {
			$offset = 0;
			$found = false;
			foreach($temp_array as $tmp_key => $tmp_val) {
				if(!$found and strtolower($val[$subkey]) > strtolower($tmp_val[$subkey])) {
					$temp_array = array_merge(
						(array)array_slice($temp_array,0,$offset),
						array($key => $val),
						array_slice($temp_array,$offset)
					);

					$found = true;
				}

				$offset++;
			}

		if(!$found) $temp_array = array_merge($temp_array, array($key => $val));
		}


	if ($sort_ascending)
		$array = array_reverse($temp_array);
	else
		$array = $temp_array;
}


echo " </table></div>";


?>
