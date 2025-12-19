<?php
$host = "mysql";
$db   = "ctf2025";
$user = "dbuser";
$pass = "dbpass";

try {
    $pdo = new PDO(
        "mysql:host=$host;dbname=$db;charset=utf8mb4",
        $user,
        $pass,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (PDOException $e) {
    die("Error BD: " . $e->getMessage());
}
?>