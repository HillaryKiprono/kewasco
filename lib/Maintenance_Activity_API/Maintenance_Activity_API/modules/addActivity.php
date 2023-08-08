<?php

// establish connection to MySQL database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "maintenance_cost_Db";

$conn = mysqli_connect($servername, $username, $password, $dbname);

// check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
else{
   
    $categoryName=$_POST['CategoryName'];
    $assetName=$_POST['AssetName'];
    $activityName=$_POST['ActivityName'];
    
    $sqlInsertAsset="INSERT INTO  tblActivity SET CategoryName='$categoryName', AssetName='$assetName',ActivityName='$activityName'";
    $resultOfQuery=$conn->query(($sqlInsertAsset));
    if($resultOfQuery){
        echo json_encode(array("success"=>true));
        
    }
    else{
        Echo json_encode(array("success"=>false));
    }
    
}

?>