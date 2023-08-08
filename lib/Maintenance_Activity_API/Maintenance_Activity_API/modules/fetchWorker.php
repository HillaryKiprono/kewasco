<?php
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

// Fetch data from the tblActivity table
$sql = "SELECT workerName FROM tblWorkers";
$result = $conn->query($sql);

// Convert data to JSON format
$data = array();
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}
echo json_encode($data);

// Close connection
$conn->close();
?>
