<?php
$serveraddress = 'http://yourdomain.ie/server.php';

if(isset($_REQUEST['sa'])){
$sa = $_REQUEST['sa'];
} else {
$sa = $serveraddress;
}
if(isset($_REQUEST['hn'])){
$hn = $_REQUEST['hn'];
} else { 
$hn = $_SERVER['SERVER_NAME'];
}
file($sa.'?hn='.$hn);
?>