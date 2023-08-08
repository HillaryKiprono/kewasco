<?php
// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "maintenance_cost_Db";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

else{
    //  $assetId=$_POST['AssetId'];
    $assetName=$_POST['AssetName'];
    $categoryName=$_POST['CategoryName'];
    
    $sqlInsertAsset="INSERT INTO  tblAssetDetails SET AssetName='$assetName',CategoryName='$categoryName'";
    $resultOfQuery=$conn->query(($sqlInsertAsset));
    if($resultOfQuery){
        echo json_encode(array("success"=>true));
    }
    else{
        Echo json_encode(array("success"=>false));
    }
    
}

?>