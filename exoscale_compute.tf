resource "exoscale_compute" "compute-1" {
    zone = "de-muc-1"
    display_name = "instance-1"
    template = "Linux Ubuntu 18.04 LTS 64-bit"
    size = "Micro"
    disk_size = 10
    key_pair = ""
    security_groups = ["${exoscale_security_group.security-group-1.name}"]
    user_data = <<EOF
#!/bin/bash
apt update
apt install -y nginx
apt install -y php-fpm
apt install -y s3cmd

echo "[default]
host_base = sos-"${var.exoscale_zone}".exo.io
host_bucket = "${var.exoscale_bucket}"
access_key = "${var.exoscale_key}"
secret_key = "${var.exoscale_secret}"
use_https = True" >/etc/sos.s3cfg

echo 'server {
    listen 80;
    root /var/www/html;
    index index.php;
    server_name clc-iaas.com;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
    }

    location ~ /\.ht$ {
        deny all;
    }
}' >/etc/nginx/sites-available/default

systemctl reload nginx

echo '<?php

$url = "s3://${var.exoscale_bucket}";

session_start();

function saveInObjectStorage($text){
	global $url;
	$text = trim($text);
	
    $timestamp = time();
	$id = rand();
	$filename = strval($timestamp)."-".strval($id).".txt";
	
    file_put_contents($filename, $text);
	
    //$cmd = "s3cmd -c /etc/sos.s3cfg sync $url"
	$cmd = "s3cmd -c /etc/sos.s3cfg put ".$filename." ".$url;
	exec($cmd, $out, $rc);
	
	return $rc;
}

function listFromObjectStorage(){
	global $url;
	
	exec("s3cmd la ".$url." | awk {\'print \$4\'}", $output, $rc);
	$objects = array_filter($output);
	
	return $objects;
}

function getFromObjectStorage($objectname, $filename){
	global $url;
	
	$cmd = "s3cmd get ".$objectname." ".$filename." --skip-existing";
	exec($cmd, $out2, $rc);
	
	return $rc;
}

$uploadSuccess = false;

if(!empty($_POST["submit"]) && !empty($_POST["message"])){
	$rc = saveInObjectStorage($_POST["message"]);
	if($rc === 0){
		$uploadSuccess = true;
	}
}
?>

<!DOCTYPE html>
<html>
<head>
	<title>Cloud Computing IaaS - FH Campus Wien</title>
	<meta charset="utf-8">
	<!--<script type="text/javascript" src="./js/jquery-1.11.1.min.js"></script>-->
	<!--<script src="./js/controller.js"></script>-->
	<style>
	body {
       	margin-top: 0px;
       	margin: 0px;
        font-family: sans-serif;
        /*background-color: #cccccc;*/
        color: black;
        text-align: left;
    }
    #alt{
      	margin-top: 0px;
       	margin: 0px;
       	font-family: sans-serif;
       	background-color: black;
       	color: white;
       	text-align:left;
    }
    .centerText {
        text-align: center;
		font-size: 18px;
    }
    .centerWhiteText {
        text-align: center;
		font-size: 18px;
        color: white;
    }
    p {
        font-size: 12px;
    }
    .bold {
       	font-weight: bold;
    }       
    .outer {
        display: table;
        position: absolute;
        height: 100%;
        width: 100%;
    }
    .middle {
		display: table-cell;
		vertical-align: middle;
    }
    .inner {
		margin-left: auto;
        margin-right: auto; 
		width: 400px;
        background-color: #1856ee;
    }
	#content{
		/*position: fixed;*/
		width: 60%;
		margin: 0 auto;
		padding-top: 2%;
		padding-left: 5%;
		padding-right: 5%;
		/*border: 1px solid;*/
	}
    #nav {
      	width: 100%;
    }
    #nav ul {
       	background-color: #4e75ff;
       	list-style-type: none;
       	margin-top: 0px;
       	margin: 0 auto;
       	padding: 0;
       	overflow: hidden;
       	font-weight: bold;
		text-align: center;
    	text-decoration: none;
    	text-transform: uppercase;
    	height:40px;
    }
    #nav li {
        float: left;
        display: inline;
        margin: 0px;
        /*color: white;*/
    }
    #nav li {
        display: block;
        color: white;
        padding: 10px 10px;
        -webkit-transition: color .15s;
        -moz-transition: color .15s;
        -ms-transition: color .15s;
        -o-transition: color .15s;
        transition: color .15s;
    }
	#footer{
		/*position: fixed;*/
		width: 100%;
		margin: 0 auto;
		text-align: center;
		color: grey;
		/*border: 1px solid;*/
	}
    #nav li:link, #nav li:visited{
        text-decoration: none;
        margin-top: 0 auto;
    }       
    #nav li:hover, #nav li:active {
        color: #3dc9ff;
    }
	a.vcheader, a.vcstagehead, a.vcserver{
		text-decoration: none;
		text-transform: none;
	}
	a.vcheader:visited, a.vcstagehead:visited, a.vcserver:visited{
		text-decoration: none;
		text-transform: none;
	}
	a.vcheader:hover, a.vcstagehead:hover, a.vcserver:hover{
		text-decoration: none;
		text-transform: none;
	}
	#inputContainer {
		margin-top: 0px;
        padding: 0px;
    }
	textarea#messageBox {
		width: 440px;
		/*width: 94%;*/
		height: 120px;
		border: 2px solid #cccccc;
		/*margin: 0 auto;*/
		padding-left: 10px;
		padding-right: 10px;
		font-family: sans-serif, Tahoma;
		font-size: 12px;
		padding: 10px;
		/*background-image: url(bg.gif);
		background-position: bottom right;
		background-repeat: no-repeat; */
	}
	.textinput {
		margin-top: 4px;
		background-color: #2E2E2E;
		color: #0CF79D;
		/*color: #BDBDBD;*/
		border: 0px;
		/*background-color: #BDBDBD;*/
	}
	#listContainer{
		height: 300px;
        width: 460px;
		overflow-y: auto;
		border: 0px solid;
		margin-top: 0px;
		padding-left: 2px;
		padding-right: 2px;
    }
	</style>
</head>
<body>
<div id="nav">
<ul>
	<!-- <li><a id="nav" href="startpage.php">Start</a></li> -->
	<li id="start">Start</li>
</ul>
</div>
<!-- -->
<div id="content">
<!-- <img src="./img/fh.svg" alt="FH Campus Wien" width="20%"> -->
<h2>Welcome to the Cloud Computing IaaS Demo</h2>
<p>Please test our S3 Object Storage implementation<p>
<div id="listContainer">
<?php
$objects = listFromObjectStorage();
foreach($objects as $i => $objectname){
    $filename = substr($objectname,strrpos($objectname,"/")+1);
	$rc = getFromObjectStorage($objectname, $filename);
	if($rc === 0){
		$message = file_get_contents($filename);
		echo("<p>".$message."</p>");
	}
}
?>
</div>
<div id="inputContainer">
	<form id="inputform" method="post" accept-charset="utf-8">
		<textarea id="messageBox" rows="10" cols="40" name="message" form="inputform"></textarea>
		<br>
		<input type="submit" name="submit" value="   Save   ">
	</form>
</div>
<!-- -->
<div id="footer">
<p class="footertext">copyright &copy; 2019 FH Campus Wien</p>
</div>
</body>
</html>

<?php
if(!empty($_POST["submit"]) && !empty($_POST["message"])){
	$_SESSION["session_message"] = $_POST["message"];
}
?>
' >/var/www/html/index.php
EOF

}
