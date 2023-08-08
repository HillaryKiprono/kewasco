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

// $categoryId = $_POST['CategoryId'];
$categoryName = $_POST['CategoryName'];

// Prepare the SQL statement
$stmt = $conn->prepare("INSERT INTO tblCategory (CategoryName) VALUES (?)");
$stmt->bind_param("s",$categoryName);

// Execute the prepared statement
if ($stmt->execute()) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false));
}

$stmt->close();
$conn->close();
?>
