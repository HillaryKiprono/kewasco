<?php
$servername = 'localhost';
$username = 'root';
$password = '';
$database = 'maintenance_cost_Db';

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
  die('Connection failed: ' . $conn->connect_error);
}

$categoryName = $_POST['CategoryName'];
$assetName = $_POST['AssetName'];
$activityName = $_POST['ActivityName'];
$workerName = $_POST['WorkerName'];
$status = $_POST['Status'];
$date = $_POST['Date'];
$time = $_POST['Time'];

$sql = "INSERT INTO fieldActivity(CategoryName, AssetName, ActivityName, WorkerName, Status, Date, Time)
        VALUES ('$categoryName', '$assetName', '$activityName', '$workerName', '$status', '$date', '$time')";

if ($conn->query($sql) === TRUE) {
  echo 'Data synced successfully';
} else {
  echo 'Error: ' . $sql . '<br>' . $conn->error;
}

$conn->close();
?>
