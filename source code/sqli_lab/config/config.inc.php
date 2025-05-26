<?php

// Database configuration
$db_server = "localhost";
$db_user = "dvwauser";
$db_password = "dvwapass";
$db_database = "dvwa";

// Create database connection
$db_connection = mysqli_connect($db_server, $db_user, $db_password, $db_database);

// Check connection
if (!$db_connection) {
    die("Database connection failed: " . mysqli_connect_error());
}

// Set default security level
if (!isset($_COOKIE["security"])) {
    setcookie("security", "low");
}

// Set default PHPIDS status
if (!isset($_COOKIE["phpids"])) {
    setcookie("phpids", "off");
}

// Security headers
header("X-Frame-Options: DENY");
header("X-XSS-Protection: 1; mode=block");
header("X-Content-Type-Options: nosniff");
header("Content-Security-Policy: default-src 'self'");

// Session security
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// CSRF protection
if (!isset($_SESSION['token'])) {
    $_SESSION['token'] = bin2hex(random_bytes(32));
}

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

?>
