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

// Retrieve POST data
$username = $_POST["username"];
$role = $_POST["role"];
$password = md5($_POST["password"]);

// Insert user into the database
$sql = "INSERT INTO users (username, role, password) VALUES ('$username', '$role', '$password')";

if ($conn->query($sql) === TRUE) {
    echo "User inserted successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
