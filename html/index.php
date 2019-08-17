<?php

if (isset($_REQUEST['view_source'])) {
	highlight_file(__FILE__);
	exit();
}

if (!isset($_COOKIE['flag'])) {
	setcookie("flag", "the_flag_is_in_here");
}

if (isset($_REQUEST['pl'])) {

	$pl = $_GET['pl'];

	if (!is_array($pl)) {
		$pl = array($pl);
	}

	if (count($pl) > 10) {
		die('nope');
	}

	for($i = 0; $i < count($pl); $i++) {
		$arg = substr($pl[$i], 0, 13);
?>
<div>
	<p class="group_name" id="name_<?=$i?>"><em><?=htmlentities($arg)?></em></p>
	<input type="text" id="id_<?=$i?>" value="<?=$arg?>">
</div>
<?php }} else { ?>
<b>Usage</b>: Enter the parameter like as in <a href="?pl=work">this</a>
<?php } ?>
