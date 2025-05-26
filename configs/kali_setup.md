# Kali Linux Setup Guide for SQL Injection Lab

## Prerequisites
- Kali Linux installed (physical or virtual machine)
- Root access
- Internet connection
- At least 2GB RAM recommended
- At least 20GB disk space

## Step 1: Update System
```bash
# Update package lists and upgrade existing packages
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
```

## Step 2: Install Required Tools
```bash
# Install web server and database
apt-get install -y apache2 php php-mysql mysql-server

# Install security testing tools
apt-get install -y sqlmap
apt-get install -y wireshark
apt-get install -y nmap
apt-get install -y git
apt-get install -y curl
```

## Step 3: Configure Apache
```bash
# Enable necessary modules
a2enmod rewrite
a2enmod headers
a2enmod ssl

# Restart Apache to apply changes
service apache2 restart
```

## Step 4: Configure MySQL
```bash
# Secure MySQL installation
mysql_secure_installation
```
During installation, you will be prompted to:
- Set root password (choose a strong password)
- Remove anonymous users: Yes
- Disallow root login remotely: Yes
- Remove test database: Yes
- Reload privilege tables: Yes

## Step 5: Set Up SQL Injection Lab
```bash
# Create directory and copy source files
cd /var/www/html
sudo mkdir -p sqli_lab
sudo cp -r /path/to/sql-injection-lab/source/sqli_lab/* sqli_lab/

# Set proper permissions
sudo chown -R www-data:www-data sqli_lab/
sudo chmod -R 755 sqli_lab/

# Configure security level
sudo sed -i 's/\$DVWA\[\'default_security_level\'\] = \"low\";/\$DVWA\[\'default_security_level\'\] = \"high\";/' sqli_lab/config/config.inc.php
```

## Step 6: Configure DVWA Database
```bash
# Start MySQL service
sudo service mysql start

# Connect to MySQL
sudo mysql -u root -p

# Create DVWA database and user
CREATE DATABASE IF NOT EXISTS dvwa;
CREATE USER IF NOT EXISTS 'dvwauser'@'localhost' IDENTIFIED BY 'dvwapass';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwauser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## Step 8: Configure Firewall
```bash
# Allow HTTP and MySQL ports
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

# Save firewall rules
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
```

## Step 9: Verify Installation
Access DVWA: http://localhost/dvwa
   - Login: admin
   - Password: password
   - Database user: dvwauser
   - Database password: dvwapass

## Security Notes
- Never expose this environment to the internet
- Keep all tools updated
- Regularly backup configurations
- Monitor logs for suspicious activity
- Change default passwords before use
- Consider using a virtual machine for isolation

## Troubleshooting
1. If Apache won't start:
   ```bash
   sudo service apache2 status
   sudo journalctl -u apache2
   ```

2. If MySQL won't start:
   ```bash
   sudo service mysql status
   sudo journalctl -u mysql
   ```

3. If DVWA shows database connection errors:
   - Verify MySQL service is running
   - Check database credentials in DVWA config
   - Verify database permissions

## Additional Tips
- Use DVWA's security levels to adjust difficulty
- Regularly update DVWA and Buggy Web App
- Keep security tools updated
- Consider using a web application firewall for testing
- Document all findings in the results directory

## Cleanup
To remove the lab environment:
```bash
# Stop services
sudo service apache2 stop
sudo service mysql stop

# Remove web applications
sudo rm -rf /var/www/html/dvwa
sudo rm -rf /var/www/html/bwapp

# Remove databases
sudo mysql -u root -p
DROP DATABASE dvwa;
DROP DATABASE bwapp;
DROP USER 'dvwauser'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Remove firewall rules
sudo iptables -F
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
