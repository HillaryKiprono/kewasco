<?php

// establish connection to MySQL database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "maintenance_cost_Db";

$conn = mysqli_connect($servername, $username, $password, $dbname);

// check connection
if (!$conn) {
    die("Connection faiwerqry78]\led: " . mysqli_connect_error());
}

// get selected category name from request parameter
$categoryName = $_GET['CategoryName'];

// execute SQL query to fetch data based on selected category name
$sql = "SELECT AssetName FROM tblAssetDetails WHERE CategoryName = '$categoryName'";
$result = mysqli_query($conn, $sql);

// extract data from result and store in an array
$data = array();
if (mysqli_num_rows($result) > 0) {
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row['AssetName'];
    }
}

// close connection to database
mysqli_close($conn);

// return data in JSON format
header('Content-Type: application/json');
echo json_encode($data);

?>
