#!/bin/bash

# DVWA Setup Script
# This script automates the setup of Damn Vulnerable Web Application (DVWA)

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: Please run as root"
    exit 1
fi

# Check if Apache is installed
if ! command -v apache2 &> /dev/null; then
    echo "Installing Apache..."
    apt-get update
    apt-get install -y apache2
fi

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "Installing PHP..."
    apt-get install -y php php-mysql
fi

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "Installing MySQL..."
    apt-get install -y mysql-server
fi

# Download and configure SQL Injection Lab
if [ ! -d "/var/www/html/sqli_lab" ]; then
    echo "Setting up SQL Injection Lab..."
    mkdir -p /var/www/html/sqli_lab
    
    # Copy source files
    cp -r ../source/sqli_lab/* /var/www/html/sqli_lab/
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy source files"
        exit 1
    fi
fi

# Configure MySQL
echo "Configuring MySQL..."
mysql -e "CREATE DATABASE IF NOT EXISTS dvwa;"
mysql -e "CREATE USER IF NOT EXISTS 'dvwauser'@'localhost' IDENTIFIED BY 'dvwapass';"
mysql -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwauser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Configure SQL Injection Lab
echo "Configuring SQL Injection Lab..."
cd /var/www/html/sqli_lab

# Set permissions
chown -R www-data:www-data /var/www/html/sqli_lab
chmod -R 755 /var/www/html/sqli_lab

# Initialize database
mysql dvwa < database/setup.sql

# Configure security level
sed -i 's/\$DVWA\[\'default_security_level\'\] = \"low\";/\$DVWA\[\'default_security_level\'\] = \"high\";/' config/config.inc.php

# Restart Apache
echo "Restarting Apache..."
service apache2 restart

# Output completion message
echo "DVWA setup complete!"
echo "Access DVWA at http://localhost/dvwa/"
echo "Default login: admin / password"
echo "Database user: dvwauser"
echo "Database password: dvwapass"
