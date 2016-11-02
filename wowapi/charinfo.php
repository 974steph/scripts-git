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
		<td colspan="3" align="center" bgcolor="black"><font color="white"><h1><?php print $char ?></h1></font></td>
	</tr>

	<tr>
		<td width="56px">Icon</td>
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

?>
