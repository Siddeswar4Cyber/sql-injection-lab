#!/bin/bash

# Payload Tester Script
# This script tests SQLi payloads against a target URL with enhanced features

# Exit on error
set -e

# Usage function
usage() {
    echo "Usage: $0 [-u URL] [-p PARAM] [-m METHOD] [-d DELAY]"
    echo "Options:"
    echo "  -u URL         Target URL (required)"
    echo "  -p PARAM       Parameter name to test (default: param)"
    echo "  -m METHOD      HTTP method (GET/POST, default: GET)"
    echo "  -d DELAY       Delay between requests in seconds (default: 0.5)"
    echo "  -o OUTPUT_DIR  Directory to save results (default: ../results/payload_tests)"
    exit 1
}

# Default values
PARAM="param"
METHOD="GET"
DELAY=0.5
OUTPUT_DIR="../results/payload_tests"

# Parse arguments
while getopts "u:p:m:d:o:h" opt; do
    case $opt in
        u) URL="$OPTARG" ;;
        p) PARAM="$OPTARG" ;;
        m) METHOD="$OPTARG" ;;
        d) DELAY="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check required argument
if [ -z "$URL" ]; then
    usage
fi

# Validate method
if [ "$METHOD" != "GET" ] && [ "$METHOD" != "POST" ]; then
    echo "Error: Invalid HTTP method. Must be GET or POST"
    exit 1
fi

# Check if payloads directory exists
if [ ! -d "../payloads" ]; then
    echo "Error: payloads directory not found"
    exit 1
fi

# Create results directory
mkdir -p "$OUTPUT_DIR"

# Log file
LOG_FILE="$OUTPUT_DIR/$(date +%Y%m%d_%H%M%S).log"

# Function to test payload
test_payload() {
    local payload="$1"
    local category="$2"
    
    echo "[+] Testing $category payload: $payload" | tee -a "$LOG_FILE"
    
    if [ "$METHOD" = "GET" ]; then
        RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null "$URL?$PARAM=$payload")
    else
        RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$URL" -d "$PARAM=$payload")
    fi
    
    echo "Response code: $RESPONSE" | tee -a "$LOG_FILE"
    
    # Check for common SQL error patterns
    if echo "$RESPONSE" | grep -qiE "(sql|syntax|error|mysql|oracle|postgresql)"; then
        echo "[!] Potential SQL error detected" | tee -a "$LOG_FILE"
    fi
    
    echo "-" | tee -a "$LOG_FILE"
    
    # Add delay between requests
    sleep $DELAY
}

# Main execution
echo "[+] Starting payload testing against $URL" | tee -a "$LOG_FILE"
echo "[+] Using parameter: $PARAM" | tee -a "$LOG_FILE"
echo "[+] Using HTTP method: $METHOD" | tee -a "$LOG_FILE"
echo "[+] Results will be saved in: $OUTPUT_DIR" | tee -a "$LOG_FILE"

echo "\n[+] Testing generic payloads..." | tee -a "$LOG_FILE"
while IFS= read -r payload; do
    test_payload "$payload" "generic"
done < "../payloads/generic.txt"

echo "\n[+] Testing blind SQLi payloads..." | tee -a "$LOG_FILE"
while IFS= read -r payload; do
    test_payload "$payload" "blind"
done < "../payloads/blind.txt"

echo "\n[+] Testing WAF bypass payloads..." | tee -a "$LOG_FILE"
while IFS= read -r payload; do
    test_payload "$payload" "waf_bypass"
done < "../payloads/waf_bypass.txt"

echo "\n[+] Payload testing completed" | tee -a "$LOG_FILE"
echo "[+] Results saved in: $OUTPUT_DIR" | tee -a "$LOG_FILE"
echo "[+] Log file: $LOG_FILE" | tee -a "$LOG_FILE"
