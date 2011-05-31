<?php
$vhost = $_REQUEST['hn'];
$newip=$_SERVER['REMOTE_ADDR'];
if(isset($_REQUEST['hn'])){
$myFile = "hosts.txt";
$fh = fopen($myFile, 'a') or die("can't open file");
$stringData = strtotime(date("d-m-Y H:i"))." - ".date("Y-m-d H:i")." - ".$vhost." ".$newip."\n";
fwrite($fh, $stringData);
fclose($fh);
echo "IP added for ".$vhost;
}else{
$lines = file('hosts.txt');
arsort($lines);
foreach($lines as $line){
echo $line."<br>";
}
}

?>