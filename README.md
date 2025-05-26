# SQL Injection Lab

A comprehensive learning environment for understanding and testing SQL Injection vulnerabilities.

## Table of Contents
- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [Security Notes](#security-notes)
- [Contributing](#contributing)
- [License](#license)

## Project Overview
This repository serves as a controlled environment for learning about SQL Injection vulnerabilities. It includes tools, scripts, and vulnerable applications to practice and understand different types of SQL Injection attacks in a safe manner.

## Project Structure
```
sql-injection-lab/
├── configs/           # Configuration files and setup scripts
├── docs/             # Documentation
├── payloads/         # SQL injection payloads
├── results/         # Scan outputs and reports
├── scripts/         # Automation scripts
├── screenshots/     # Proof-of-concept images
├── source/          # Source code
└── vulnerable_apps/ # Local copies of test applications
```

## Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/yourusername/sql-injection-lab.git
cd sql-injection-lab
```

2. Install dependencies:
```bash
sudo apt-get update
sudo apt-get install -y apache2 php php-mysql mysql-server python3-pip git
pip3 install -r requirements.txt
```

3. Run setup script:
```bash
sudo ./configs/dvwa_setup.sh
```

4. Access DVWA:
```
http://localhost/dvwa
Default login:
Username: admin
Password: password
│   │   ├── scan_1.xml # XML reports
│   │   └── scan_1.json # JSON results
│   └── VULNERABILITY_LOG.md # Manual testing notes
├── scripts/             # Automation scripts
│   ├── sqlmap_auto.py   # SQLMap automation wrapper
│   ├── payload_tester.sh # Payload testing script
│   └── report_generator.py # Converts XML to HTML reports
├── screenshots/         # Proof-of-concept images
│   ├── login_bypass.png # Admin bypass example
│   └── db_dump.png      # Database extraction proof
├── vulnerable_apps/     # Local vulnerable applications
│   ├── dvwa/           # Damn Vulnerable Web App
│   └── bwapp/          # Buggy Web App
├── .gitignore          # Git ignore file
├── LICENSE             # Project license
└── requirements.txt    # Python dependencies
```

## Usage

### Automated Testing
Run the SQLMap automation script:
```bash
python scripts/sqlmap_auto.py -u http://localhost/dvwa/vulnerabilities/sqli/
```

### Manual Testing
1. Use payloads from `payloads/generic.txt` for basic testing
2. For blind SQLi, refer to `payloads/blind.txt`
3. For WAF bypass, use `payloads/waf_bypass.txt`

### Generating Reports
```bash
python scripts/report_generator.py -i results/scans/scan_1.xml -o results/report.html
```

## Security Notes
⚠️ **IMPORTANT**: This project is for educational purposes only. Do not use the payloads or techniques against any system without explicit permission. Always ensure you have proper authorization before testing any system.

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer
This project is intended for educational purposes only. The creators are not responsible for any misuse of the information or tools provided.
"# sql-injection-lab" 
"# sql-injection-lab" 
