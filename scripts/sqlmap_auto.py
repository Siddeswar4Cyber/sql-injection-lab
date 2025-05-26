#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import threading
from datetime import datetime
import concurrent.futures
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sqlmap_auto.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def run_sqlmap(url, output_dir, cookie=None, security_level=None, data=None, method=None, suffix=None, technique=None, threads=10, dbms=None, tamper=None, list_dbs=False, debug=False):
    """
    Run SQLMap with various options and save results
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = os.path.join(output_dir, f"scan_{timestamp}")
    
    # Create output directory if it doesn't exist
    os.makedirs(output_path, exist_ok=True)
    
    # Basic SQLMap command with common options
    sqlmap_cmd = [
        "sqlmap",
        "-u", url,
        "--batch",
        "--random-agent",
        "--level=3",
        "--risk=3",
        f"--output-dir={output_path}",
        f"--threads={threads}",
        "--output-format=xml",
        f"--xml-output-file={os.path.join(output_path, 'sqlmap_report.xml')}",
        "--verbose" if debug else "--batch"
    ]
    
    # Add --dbs option if requested
    if list_dbs:
        sqlmap_cmd.append("--dbs")
    
    # Add optional parameters
    if cookie:
        # Remove extra spaces and quotes from cookie
        cookie = cookie.strip().strip('"').strip("'")
        sqlmap_cmd.extend([f"--cookie='{cookie}'"])
    if security_level:
        sqlmap_cmd.extend([f"--level={str(security_level)}"])
    if data:
        sqlmap_cmd.extend([f"--data={data}"])
    if method and method.upper() != "GET":
        sqlmap_cmd.extend([f"-m={method}"])
    if suffix:
        # Remove extra quotes from suffix
        suffix = suffix.strip('"').strip("'")
        sqlmap_cmd.extend([f"--suffix={suffix}"])
    if technique:
        sqlmap_cmd.extend([f"--technique={technique}"])
    if dbms:
        sqlmap_cmd.extend([f"--dbms={dbms}"])
    if tamper:
        sqlmap_cmd.extend([f"--tamper={tamper}"])
    
    # Handle security level and cookie for DVWA
    if security_level:
        if security_level.lower() not in ['low', 'medium', 'high', 'impossible']:
            print(f"[!] Invalid security level: {security_level}. Must be one of: low, medium, high, impossible")
            return False
        
        # Update cookie with security level
        if not cookie:
            cookie = f"PHPSESSID={os.urandom(16).hex()}; security={security_level.lower()}"
        else:
            # Ensure security level is in cookie
            if "security=" not in cookie:
                cookie = f"{cookie}; security={security_level.lower()}"
        
        # Add cookie with proper quoting
        sqlmap_cmd.extend(["--cookie", f"'{cookie}'"])
    
    try:
        logger.info(f"[+] Starting SQLMap scan for {url}")
        logger.debug(f"SQLMap command: {sqlmap_cmd}")
        
        result = subprocess.run(sqlmap_cmd, capture_output=True, text=True)
        
        # Log SQLMap output
        logger.debug("SQLMap stdout:")
        logger.debug(result.stdout)
        logger.debug("SQLMap stderr:")
        logger.debug(result.stderr)
        
        # Save raw output
        with open(os.path.join(output_path, "raw_output.txt"), "w") as f:
            f.write(result.stdout)
            f.write("\n")
            f.write(result.stderr)
        
        # Generate HTML report if XML file exists
        xml_file = os.path.join(output_path, "sqlmap_report.xml")
        if os.path.exists(xml_file):
            try:
                from report_generator import generate_html_report
                html_file = os.path.join(output_path, "report.html")
                generate_html_report(xml_file, html_file)
                logger.info(f"[+] Generated HTML report: {html_file}")
            except Exception as e:
                logger.error(f"[!] Error generating HTML report: {str(e)}")
        
        print(f"[+] Scan completed. Results saved in {output_path}")
        return True
    
    except Exception as e:
        logger.error(f"[!] Error running SQLMap: {str(e)}")
        return False

def main():
    parser = argparse.ArgumentParser(description="SQLMap Automation Script")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-o", "--output", default="results/scans", help="Output directory")
    parser.add_argument("-c", "--cookie", help="Session cookie (e.g., PHPSESSID=value)")
    parser.add_argument("-s", "--security-level", help="DVWA security level (low, medium, high, impossible)")
    parser.add_argument("-d", "--data", help="POST data")
    parser.add_argument("-m", "--method", choices=["GET", "POST"], default="GET", help="HTTP method")
    parser.add_argument("--suffix", help="Suffix for payloads")
    parser.add_argument("--technique", help="SQL injection technique (B/E/T/U/S/Q)")
    parser.add_argument("--threads", type=int, default=10, help="Number of threads")
    parser.add_argument("--dbms", help="Target database type (e.g., MySQL, PostgreSQL)")
    parser.add_argument("--tamper", help="SQLMap tamper script")
    parser.add_argument("--all-techniques", action="store_true", help="Run all SQL injection techniques")
    parser.add_argument("--no-report", action="store_true", help="Do not generate HTML report")
    parser.add_argument("--list-dbs", action="store_true", help="List databases")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode")
    
    args = parser.parse_args()

    # If --all-techniques is specified, run multiple scans in parallel
    if args.all_techniques:
        techniques = {
            "B": "Boolean-based blind SQLi",
            "E": "Error-based SQLi",
            "T": "Time-based blind SQLi",
            "U": "Union-based SQLi",
            "S": "Stacked queries",
            "Q": "Inline queries"
        }
        
        # Create thread pool
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.threads) as executor:
            # Submit tasks for each technique
            futures = []
            for tech, desc in techniques.items():
                print(f"[+] Starting {desc} scan...")
                try:
                    # Create output directory if needed
                    os.makedirs(args.output, exist_ok=True)
                    
                    # Log scan parameters
                    logger.info(f"Starting SQLMap scan with parameters:")
                    logger.info(f"URL: {args.url}")
                    logger.info(f"Output: {args.output}")
                    logger.info(f"Cookie: {args.cookie}")
                    logger.info(f"Security Level: {args.security_level}")
                    logger.info(f"Data: {args.data}")
                    logger.info(f"Method: {args.method}")
                    logger.info(f"Suffix: {args.suffix}")
                    logger.info(f"Technique: {tech}")
                    logger.info(f"Threads: {args.threads}")
                    logger.info(f"DBMS: {args.dbms}")
                    logger.info(f"Tamper: {args.tamper}")
                    logger.info(f"List Databases: {args.list_dbs}")
                    logger.info(f"Debug Mode: {args.debug}")
                    
                    # Run SQLMap scan
                    futures.append(
                        executor.submit(
                            run_sqlmap,
                            args.url,
                            args.output,
                            cookie=args.cookie,
                            security_level=args.security_level,
                            data=args.data,
                            method=args.method,
                            suffix=args.suffix,
                            technique=tech,
                            threads=args.threads,
                            dbms=args.dbms,
                            tamper=args.tamper,
                            list_dbs=args.list_dbs,
                            debug=args.debug
                        )
                    )
                except Exception as e:
                    logger.error(f"[!] Error submitting task: {str(e)}")
            
            # Wait for all scans to complete
            for future in concurrent.futures.as_completed(futures):
                if future.result():
                    logger.info("[+] Scan completed successfully")
                else:
                    print("[!] Scan failed")
    else:
        # Run single scan with specified parameters
        if run_sqlmap(args.url, args.output, 
                     cookie=args.cookie,
                     security_level=args.security_level,
                     data=args.data,
                     method=args.method,
                     suffix=args.suffix,
                     technique=args.technique,
                     threads=args.threads,
                     dbms=args.dbms,
                     tamper=args.tamper,
                     list_dbs=args.list_dbs):
            print("[+] SQLMap scan completed successfully")
            if not args.no_report:
                print("[+] HTML report generated successfully")
        else:
            print("[!] SQLMap scan failed")

if __name__ == "__main__":
    main()
