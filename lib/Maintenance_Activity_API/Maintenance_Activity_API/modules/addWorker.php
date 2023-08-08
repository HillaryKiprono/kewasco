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
else
{
    $workerId=$_POST['workerId'];
    $workerName=$_POST['workerName'];  
    
    
    $sqlQuery="INSERT INTO  tblWorkers SET  workerName='$workerName'";
    $resultOfQuery=$conn->query($sqlQuery);
    if($resultOfQuery){
        echo json_encode(array("success"=>true));
        
    }
    else
    {
        echo json_encode(array("success"=>false));
       
    }


}





?>