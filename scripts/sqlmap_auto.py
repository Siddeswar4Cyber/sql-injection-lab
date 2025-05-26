import argparse
import json
import os
import subprocess
from datetime import datetime

def run_sqlmap(url, output_dir):
    """
    Run SQLMap with common options and save results
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
        "--level", "3",
        "--risk", "3",
        "--output-dir", output_path,
        "--threads", "5"
    ]
    
    try:
        print(f"[+] Starting SQLMap scan for {url}")
        result = subprocess.run(sqlmap_cmd, capture_output=True, text=True)
        
        # Save raw output
        with open(os.path.join(output_path, "raw_output.txt"), "w") as f:
            f.write(result.stdout)
            f.write("\n")
            f.write(result.stderr)
            
        print(f"[+] Scan completed. Results saved in {output_path}")
        return True
    
    except Exception as e:
        print(f"[!] Error running SQLMap: {str(e)}")
        return False

def main():
    parser = argparse.ArgumentParser(description="SQLMap Automation Script")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-o", "--output", default="results/scans", help="Output directory")
    
    args = parser.parse_args()
    
    if run_sqlmap(args.url, args.output):
        print("[+] SQLMap scan completed successfully")
    else:
        print("[!] SQLMap scan failed")

if __name__ == "__main__":
    main()
