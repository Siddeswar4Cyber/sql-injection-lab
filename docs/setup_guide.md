# SQL Injection Lab Setup and Usage Guide

## 1. Initial Setup

### 1.1 System Preparation
#### Install Kali Linux
1. Download Kali Linux ISO from official website
2. Create bootable USB drive
3. Install Kali Linux
4. Update system:
#### or on Virtual BOX Best chocie
```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
```

### 1.2 Install Required Tools
```bash
# Install web server and PHP
sudo apt-get install -y apache2 php php-mysql

# Install database server
sudo apt-get install -y mysql-server

# Install security testing tools
sudo apt-get install -y sqlmap
sudo apt-get install -y wireshark
sudo apt-get install -y nmap
sudo apt-get install -y git
sudo apt-get install -y curl
```

### 1.3 Configure Apache
```bash
# Enable necessary modules
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod ssl

# Configure Apache settings
sudo nano /etc/apache2/apache2.conf
# Add these lines:
ServerSignature Off
ServerTokens Prod

# Restart Apache
sudo service apache2 restart
```

## 2. Project Setup

### 2.1 Clone Repository
```bash
# Create project directory
mkdir -p ~/sql-injection-lab

cd ~/sql-injection-lab

# Clone repository
git clone https://github.com/Siddeswar4Cyber/sql-injection-lab.git

cd sql-injection-lab

# Install Python dependencies
pip3 install -r requirements.txt
```

### 2.2 Configure Environment
```bash
# Set up DVWA environment
sudo ./configs/dvwa_setup.sh

# Verify installation
sudo service apache2 status
sudo service mysql status
```

## 3. Database Configuration

### 3.1 Secure MySQL Installation
```bash
# Run secure installation
sudo mysql_secure_installation

# During installation:
# - Set root password: Yes
# - Remove anonymous users: Yes
# - Disallow root login remotely: Yes
# - Remove test database: Yes
# - Reload privilege tables: Yes
```

### 3.2 Create DVWA Database
```bash
# Access MySQL
sudo mysql -u root -p

# Create DVWA database and user
CREATE DATABASE IF NOT EXISTS dvwa;
CREATE USER IF NOT EXISTS 'dvwauser'@'localhost' IDENTIFIED BY 'dvwapass';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwauser'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import sample data
mysql dvwa < /var/www/html/sqli_lab/database/setup.sql
```

## 4. Application Configuration

### 4.1 Configure Security Level
```bash
# Access DVWA
firefox http://localhost/dvwa

# Set security level:
# - Low: No protection
# - Medium: Basic filtering
# - High: Advanced protection
# - Impossible: Prepared statements

# Default login:
Username: admin
Password: password
```

### 4.2 Configure Firewall
```bash
# Allow HTTP and MySQL ports
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

# Save firewall rules
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
```

## 5. Testing Procedures

### 5.1 Basic Testing
```bash
# Start payload tester
./scripts/payload_tester.sh -u http://localhost/dvwa/vulnerabilities/sqli/

# Test different security levels:
./scripts/payload_tester.sh -u http://localhost/dvwa/vulnerabilities/sqli/ -p id -m GET -d 0.5
```

### 5.2 Automated Testing with Scripts

#### 1. Basic Testing with Payload Tester
```bash
# Test all security levels
./scripts/payload_tester.sh -u http://localhost/dvwa/vulnerabilities/sqli/

# Test specific security level
./scripts/payload_tester.sh -u http://localhost/dvwa/vulnerabilities/sqli/ -s low
./scripts/payload_tester.sh -u http://localhost/dvwa/vulnerabilities/sqli/ -s medium
./scripts/payload_tester.sh -u http://localhost/dvwa/vulnerabilities/sqli/ -s high
```

#### 2. Advanced SQLMap Testing with Automation Script
```bash
# Run automated SQLMap tests
./scripts/sqlmap_auto.py -u "http://localhost/dvwa/vulnerabilities/sqli/" \
  -c "PHPSESSID=f4f8bd7a806d9c5bc733a4676647b1de" \
  -s "low,medium,high"

# Test specific security level
./scripts/sqlmap_auto.py -u "http://localhost/dvwa/vulnerabilities/sqli/" \
  -c "PHPSESSID=f4f8bd7a806d9c5bc733a4676647b1de" \
  -s "medium"
```

#### 3. Custom SQLMap Testing
```bash
# Basic scan using SQLMap
./scripts/sqlmap_auto.py -u "http://localhost/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
  -c "PHPSESSID=f4f8bd7a806d9c5bc733a4676647b1de; security=low" \
  --batch --dbs

# Medium security level scan
./scripts/sqlmap_auto.py -u "http://localhost/dvwa/vulnerabilities/sqli/" \
  -c "PHPSESSID=f4f8bd7a806d9c5bc733a4676647b1de; security=medium" \
  --data="id=1&Submit=Submit" \
  --method POST \
  --random-agent \
  --risk 3

# High security level scan
./scripts/sqlmap_auto.py -u "http://localhost/dvwa/vulnerabilities/sqli/session-input.php" \
  -c "PHPSESSID=f4f8bd7a806d9c5bc733a4676647b1de; security=high; id=1" \
  -p id \
  --level=5 \
  --technique=Q \
  --prefix="' " \
  --suffix=" -- "
```

### 5.3 Manual Testing
1. Access DVWA in browser
2. Set security level
3. Test different parameters:
   - id parameter (GET)
   - user parameter (POST)
   - session parameters
4. Use different payloads:
   - Generic SQLi
   - Blind SQLi
   - Time-based SQLi
   - WAF bypass

## 6. Report Generation

### 6.1 Automated Report Generation
```bash
# Generate comprehensive reports
./scripts/report_generator.py \
  -i "results/scans/scan_*.xml" \
  -o "results/reports/report_$(date +%Y%m%d_%H%M%S)" \
  --format all

# Generate specific format
./scripts/report_generator.py \
  -i "results/scans/scan_*.xml" \
  -o "results/reports/report_$(date +%Y%m%d_%H%M%S)" \
  --format html

./scripts/report_generator.py \
  -i "results/scans/scan_*.xml" \
  -o "results/reports/report_$(date +%Y%m%d_%H%M%S)" \
  --format json
```

### 6.2 Report Analysis
```bash
# Analyze reports
./scripts/report_generator.py \
  -i "results/scans/scan_*.xml" \
  -o "results/analysis/analysis_$(date +%Y%m%d_%H%M%S)" \
  --analyze

# Generate summary
./scripts/report_generator.py \
  -i "results/scans/scan_*.xml" \
  -o "results/analysis/summary_$(date +%Y%m%d_%H%M%S)" \
  --summary
```

### 6.3 Report Organization
1. Scans are automatically organized by date
2. Reports include:
   - Vulnerability details
   - Exploitation methods
   - Database access patterns
   - Response analysis
   - Security recommendations
3. Use the analysis scripts to:
   - Track progress
   - Compare different tests
   - Generate statistics
   - Create visualizations

## 7. Cleanup and Security

### 7.1 Stop Services
```bash
# Stop Apache
sudo service apache2 stop

# Stop MySQL
sudo service mysql stop

# Stop other services
sudo service php7.4-fpm stop
```

### 7.2 Remove Applications
```bash
# Remove DVWA
sudo rm -rf /var/www/html/dvwa

# Remove database
sudo mysql -u root -p
DROP DATABASE dvwa;
DROP USER 'dvwauser'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Remove firewall rules
sudo iptables -F
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
```

### 7.3 Secure System
```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Remove unused packages
sudo apt-get autoremove -y

# Clean up logs
sudo journalctl --vacuum-time=1d

# Check for rootkits
sudo rkhunter --check
```

## 8. Troubleshooting

### 8.1 Apache Issues
```bash
# Check Apache status
sudo service apache2 status

# View Apache logs
sudo tail -f /var/log/apache2/error.log

# Common fixes:
# 1. Check permissions:
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# 2. Check configuration:
sudo nano /etc/apache2/sites-available/000-default.conf
```

### 8.2 MySQL Issues
```bash
# Check MySQL status
sudo service mysql status

# View MySQL logs
sudo tail -f /var/log/mysql/error.log

# Common fixes:
# 1. Check permissions:
sudo mysql -u root -p
SHOW GRANTS FOR 'dvwauser'@'localhost';

# 2. Check database:
USE dvwa;
SHOW TABLES;
```

### 8.3 SQLMap Issues
```bash
# Check SQLMap version
sqlmap -hh

# Common fixes:
# 1. Update SQLMap:
sqlmap --update

# 2. Check dependencies:
sqlmap --dependencies
```

## 9. Security Recommendations

### 9.1 During Testing
1. Never expose this environment to the internet
2. Keep all tools updated
3. Regularly backup configurations
4. Monitor logs for suspicious activity
5. Use strong passwords
6. Enable firewall rules
7. Regular security audits

### 9.2 After Testing
1. Remove all test data
2. Reset passwords
3. Clean up temporary files
4. Remove firewall rules
5. Stop all services
6. Update system
7. Run security scans

## 10. Additional Resources

### 10.1 Documentation
- [Project README](../README.md)
- [Kali Setup Guide](../configs/kali_setup.md)
- [SQL Injection Techniques](../source/sqli_lab/techniques/sqli_techniques.md)

### 10.2 Tools
- SQLMap documentation: https://sqlmap.org/
- DVWA documentation: https://github.com/digininja/DVWA
- OWASP SQL Injection Prevention Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
- Web Application Firewall (WAF) Guide: https://owasp.org/www-project-web-application-firewall/

### 10.3 Learning Resources
- SQL Injection Tutorial: https://portswigger.net/web-security/sql-injection
- Advanced SQL Injection: https://www.sqlinjection.net/
- SQL Injection Prevention: https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
- SQLMap Usage Guide: https://github.com/sqlmapproject/sqlmap/wiki/Usage
