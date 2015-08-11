<?php
$docid="nHojinAxlItS8cpdmruQ19QH0o";
$keyid="Bi8gRZh1EvnTdAahg8eWdoQG1Nus";
$url="https://www.googleapis.com/fusiontables/v2/query";
#$fileget="$url?sql=SELECT%20ROWID%20FROM%20$docid&key=$keyid";
#echo "$fileget<br>";
set_include_path(get_include_path() . PATH_SEPARATOR . '/home/animeshs/public_html/public-html-ani/nitrogen-tank/google-api-php-client/src/');
require_once '/home/animeshs/public_html/public-html-ani/nitrogen-tank/google-api-php-client/src/Google/autoload.php'; // or wherever autoload.php is located

$client = new Google_Client();
$client->setApplicationName('cell-line-in-tank');
$client->setScopes(array('https://www.googleapis.com/auth/fusiontables'));
$client->setClientId('73800148-rcbu1kalnnha3um3vad6j9ejvbf.apps.googleusercontent.com');
$client->setClientSecret('uoSFHxa-1fYrtfgWfk');
$client->setRedirectUri('none');
$client->setClientId('785570148-mstm92ds0s8jnquj79nog4nnp7.apps.googleusercontent.com');
$client->setClientSecret('DTX_qs_gcZExWvVcqUVM');
$client->setRedirectUri('urn:ietf:wg:oauth:2.0:oobhttp://localhost');
$client->setAccessType('offline');
$client->setDeveloperKey('AIzayh87P_6DzjGoKQLugbSmsOp_20');
#$client->setAccessToken('ya19.iAEF1bVrnyGY62JVtI0w51237dBIkh2b9qlj0C3JfTxE8jy7r5mfwRwf-1LdzD2_sg'); // The access JSON object.
$keyid=$client->getAccessToken();
#if( $client->isAccessTokenExpired() ){
#	$client->refreshToken('4/yWn659s3SpluQq51CdlzgAOBouRID8hd5ebYHk');
#}
#$client->setDeveloperKey($keyid);
$keyid="1/AW2FKFEKRs-f-RIjfoBsQopwGKTacVxXg.IqeKm1UZrjMoGjtSfTqMABRrmwI";
#$service = new Google_Service_Books($client);
$keyid="4/9byJTODyZOX5g4y1Blqa9brb8McHj39RsGgcsM";
$keyid="y19.iAHw-Dx0_QA0noU2p-e7SACsa5cfCpGczAGTDFrKEhu6sw9bEDWJD26rdUpgcurApycw";
echo $client->getAccessToken(),"<br>";
print_r(json_decode($keyid));

#$fileget="https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20*%20FROM%201U_BJ6XlyY_dC8rN8LHkNhizyi4o2&key=AIzaSyCui8gRZh1EvnTdAahg8eWdoQG1Nus";
echo "<form method=post action='input.php'>";
echo "<b>SELECT</b> <select name='tank'>";
$range = range(1,3);
foreach ($range as $tank) {
	if($tank==$_POST['tank']){ echo "<option value='$tank' selected>$tank Tank</option>";}
else{ echo "<option value='$tank'>$tank Tank</option>";}
}
echo "</select>";

echo "<select name='rack'>";
$range = range(1,6);
foreach ($range as $rack) {
	if($rack==$_POST['rack']){ echo "<option value='$rack' selected>$rack Rack</option>";}

else{  echo "<option value='$rack'>$rack Rack</option>";}
}
echo "</select>";

echo "<select name='box'>";
$range = range(1,10);
foreach ($range as $box) {
	if($box==$_POST['box']){ echo "<option value='$box' selected>$box Box</option>";}
  else{echo "<option value='$box'>$box Box</option>";}
}
echo "</select>";

echo "<select name='num'>";
$range = range(1,100);
foreach ($range as $num) {
	if($num==$_POST['num']){ echo "<option value='$num' selected>$num Number</option>";}
else{ echo "<option value='$num'>$num Number</option>"; }
}
echo "</select>";
echo "<input type=submit value=Submit>";
#echo "</form>";
#echo "<form method=post action='input.php'>";

$num=$_POST['num'];
$box=$_POST['box'];
$rack=$_POST['rack'];
$tank=$_POST['tank'];

$id=$num+100*($box-1)+(($rack-1)*10*100)+(($tank-1)*6*10*100);

$squery="SELECT ROWID, RowNum, Tank, Rack, Box, Number, CellLine, TubeLabel, Morphology, ATCC, Location, Contact  FROM $docid WHERE RowNum = $id";
#$squery="SELECT ROWID, RowNum, Tank, Rack, Box, Number, CellLine, TubeLabel, Morphology, ATCC, Location, Contact FROM $docid WHERE RowNum = $id";
$data=http_build_query(array('sql' => $squery));
$options = array(
    'http' => array(
        'method'  => 'POST',
        'content' => $data,
        'header' => array("Authorization: Bearer $keyid",'Content-type: application/x-www-form-urlencoded')
    )
);
$context  = stream_context_create($options);
#echo "Contect:",$context,$data;
$result = file_get_contents($url, false, $context);
#$json_string =    file_get_contents($result);
$parsed_json = json_decode($result);
#print_r($parsed_json);
#foreach($parsed_json->columns as $value) {	echo $value,"\t";}
echo "<br /> \n";

#foreach($parsed_json->rows as $value) {
	#foreach($value as $value2) {
#		echo $value,"\t";
	#}
#	echo "<br /> \n";
#}
$rowid=$parsed_json->rows[0][0];
$rownum=$parsed_json->rows[0][1];
$tank=$parsed_json->rows[0][2];
$rack=$parsed_json->rows[0][3];
$box=$parsed_json->rows[0][4];
$num=$parsed_json->rows[0][5];
$celllineold=$parsed_json->rows[0][6];
$labeltubeold=$parsed_json->rows[0][7];
$morphold=$parsed_json->rows[0][8];
$ATCCold=$parsed_json->rows[0][9];
$locationold=$parsed_json->rows[0][10];
$contactold=$parsed_json->rows[0][11];

echo "Selected Tank-$tank Rack-$rack Box-$box,Number-$num [RowID: $rowid]<br>";
echo "<b>Cell Line: </b> &nbsp &nbsp $celllineold => <INPUT TYPE = 'text'  name = 'cellline'> <br>";
echo "<b>Tube Label:  </b>   $labeltubeold   =>  <INPUT TYPE = 'text'  name = 'labeltube'> <br>";
echo "<b>Morphology:  </b> $morphold   => <INPUT TYPE = 'text'   name = 'morph'>  <br>";
echo "<b>ATCC:  </b>  &nbsp &nbsp &nbsp $ATCCold   => <INPUT TYPE = 'text'   name = 'ATCC'> <br>";
echo "<b>Location: </b> &nbsp &nbsp $locationold   => <INPUT TYPE = 'text'   name = 'location'> <br>";
echo "<b>Contact: </b> &nbsp  &nbsp $contactold   => <INPUT TYPE = 'text'   name = 'contact'> <br>";
echo "<input type=submit value=Update>";
echo "</form>";

if($_POST['cellline']){$celllinenew=$_POST['cellline'];}
else{$celllinenew=$celllineold;}
if($_POST['labeltube']){$labeltubenew=$_POST['labeltube'];}
else{$labeltubenew=$labeltubeold;}
if($_POST['morph']){$morphnew=$_POST['morph'];}
else{$morphnew=$morphold;}
if($_POST['ATCC']){$ATCCnew=$_POST['ATCC'];}
else{$ATCCnew=$ATCCold;}
if($_POST['location']){$locationnew=$_POST['location'];}
else{$locationnew=$locationold;}
if($_POST['contact']){$contactnew=$_POST['contact'];}
else{$contactnew=$contactold;}
echo "$celllinenew,$labeltubenew,$morphnew,$ATCCnew,$locationnew,$contactnew<br>";

$squery="UPDATE $docid SET CellLine = '$celllinenew' , Morphology = '$morphnew', TubeLabel = '$labeltubenew' , Morphology = '$morphnew' , ATCC = '$ATCCnew' , Location = '$locationnew' , Contact = '$contactnew' WHERE ROWID = '$rowid'";
#$squery="UPDATE $docid SET CellLine = 'teat' WHERE ROWID = '2'";#.$rowid."'";
$data=http_build_query(array('sql' => $squery));
$options = array(
    'http' => array(
        'method'  => 'POST',
        'content' => $data,
	'header' => array("Authorization: Bearer $keyid",'Content-type: application/x-www-form-urlencoded')
    )
);
$context  = stream_context_create($options);
#echo "Contect:",$context,$data;
$result = file_get_contents($url, false, $context);
var_dump($result);

echo "<br> <br> <a href='https://www.google.com/fusiontables/DataSource?docid=$docid#rows:id=1'> View Complete Table </a> <br>";
 

?>
