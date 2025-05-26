<?php
session_start();

// Security level check
if(!isset($_COOKIE["security"])) {
    $_COOKIE["security"] = "low";
}

// Connect to database
require_once "../../config/config.inc.php";

// Get user input
if(isset($_GET['id'])) {
    $id = $_GET['id'];
} else {
    $id = "1";
}

// Low security level - vulnerable to SQL injection
if($_COOKIE["security"] == "low") {
    $query = "SELECT first_name, last_name FROM users WHERE user_id = '$id'";
}

// Medium security level - vulnerable to blind SQL injection
else if($_COOKIE["security"] == "medium") {
    $query = "SELECT first_name, last_name FROM users WHERE user_id = '" . mysqli_real_escape_string($GLOBALS["$db_connection"], $id) . "'";
}

// High security level - vulnerable to time-based SQL injection
else if($_COOKIE["security"] == "high") {
    $query = "SELECT first_name, last_name FROM users WHERE user_id = '" . mysqli_real_escape_string($GLOBALS["$db_connection"], $id) . "' LIMIT 1";
}

// Execute query
$result = mysqli_query($GLOBALS["$db_connection"], $query);

// Display results
if($result && mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    echo "<h2>User Details</h2>";
    echo "<p>First Name: " . htmlspecialchars($row['first_name']) . "</p>";
    echo "<p>Last Name: " . htmlspecialchars($row['last_name']) . "</p>";
} else {
    echo "<p>No user found with that ID.</p>";
}

// SQL Injection Test Form
?>

<!DOCTYPE html>
<html>
<head>
    <title>SQL Injection Vulnerability</title>
</head>
<body>
    <h1>SQL Injection Test</h1>
    <form method="get" action="">
        <label for="id">User ID:</label>
        <input type="text" name="id" id="id" value="<?php echo htmlspecialchars($id); ?>">
        <input type="submit" value="Submit">
    </form>
    
    <h2>Security Level: <?php echo htmlspecialchars($_COOKIE["security"]); ?></h2>
    
    <?php if(isset($_GET['id'])): ?>
    <div class="query">
        <h3>SQL Query:</h3>
        <pre><?php echo htmlspecialchars($query); ?></pre>
    </div>
    <?php endif; ?>
</body>
</html>
