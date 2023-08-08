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

// execute SQL query to fetch data
$sql = "SELECT CategoryName FROM tblCategory";
$result = mysqli_query($conn, $sql);

// extract data from result and store in an array
$data = array();
if (mysqli_num_rows($result) > 0) {
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row['CategoryName'];
    }
}

// close connection to database
mysqli_close($conn);

// return data in JSON format
header('Content-Type: application/json');
echo json_encode($data);

?>
