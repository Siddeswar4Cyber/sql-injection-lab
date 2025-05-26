#!/bin/bash

# Payload Tester Script
# This script tests SQLi payloads against a target URL with enhanced features

# Exit on error
set -e

# Usage function
usage() {
    echo "Usage: $0 [-u URL] [-p PARAM] [-m METHOD] [-d DELAY] [-s SECURITY] [-c COOKIE]"
    echo "Options:"
    echo "  -u URL         Target URL (required)"
    echo "  -p PARAM       Parameter name to test (default: id)"
    echo "  -m METHOD      HTTP method (GET/POST, default: GET)"
    echo "  -d DELAY       Delay between requests in seconds (default: 0.5)"
    echo "  -s SECURITY    Security level (low, medium, high, impossible)"
    echo "  -c COOKIE      Session cookie value"
    echo "  -o OUTPUT_DIR  Directory to save results (default: ../results/payload_tests)"
    exit 1
}

# Logging function
log() {
    local message="$1"
    local level="$2"
    
    # Get current timestamp
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Format message based on level
    local formatted_message="[$timestamp]"
    
    case "$level" in
        INFO)
            formatted_message="$formatted_message INFO: $message"
            ;;
        WARN)
            formatted_message="$formatted_message WARN: $message"
            ;;
        ERROR)
            formatted_message="$formatted_message ERROR: $message"
            ;;
        *)
            formatted_message="$formatted_message $message"
            ;;
    esac
    
    # Write to terminal and log file
    echo -e "$formatted_message"
    echo -e "$formatted_message" >> "$LOG_FILE"
}

# Default values
PARAM="id"
METHOD="GET"
DELAY=0.5
OUTPUT_DIR="../results/payload_tests"
SECURITY="low"
COOKIE=""

# Parse arguments
while getopts "u:p:m:d:s:c:o:h" opt; do
    case $opt in
        u) URL="$OPTARG" ;;
        p) PARAM="$OPTARG" ;;
        m) METHOD="$OPTARG" ;;
        d) DELAY="$OPTARG" ;;
        s) SECURITY="$OPTARG" ;;
        c) COOKIE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check required arguments
if [ -z "$URL" ]; then
    echo "Error: URL is required"
    usage
fi

# Validate security level
if ! echo "$SECURITY" | grep -qiE "^(low|medium|high|impossible)$"; then
    echo "Error: Invalid security level. Must be low, medium, high, or impossible"
    exit 1
fi

# Validate HTTP method
if [ "$METHOD" != "GET" ] && [ "$METHOD" != "POST" ]; then
    echo "Error: Invalid HTTP method. Must be GET or POST"
    exit 1
fi

# Create output directory
OUTPUT_DIR=$(realpath "$OUTPUT_DIR")
if ! mkdir -p "$OUTPUT_DIR" 2>/dev/null; then
    echo "Error: Failed to create output directory: $OUTPUT_DIR"
    exit 1
fi

# Initialize log file
timestamp=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$OUTPUT_DIR/${timestamp}_${SECURITY}.log"

# Create and set permissions
if ! touch "$LOG_FILE" 2>/dev/null; then
    echo "Error: Failed to create log file: $LOG_FILE"
    exit 1
fi

# Set proper permissions
if ! chmod 666 "$LOG_FILE" 2>/dev/null; then
    echo "Warning: Could not set permissions on log file"
fi

# Verify log file is writable
if ! [ -w "$LOG_FILE" ]; then
    echo "Error: Log file is not writable: $LOG_FILE"
    exit 1
fi

# Function to test payload
test_payload() {
    local payload="$1"
    local category="$2"

    # Skip comments and empty lines
    [[ -z "$payload" || "$payload" =~ ^# ]] && return

    # Clean payload - handle quotes and special characters
    payload=$(echo "$payload" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sed 's/\"/\\"/g')

    [[ -z "$payload" ]] && return

    # Prepare display payload with proper escaping
    local display_payload=$(echo "$payload" | sed 's/\\n/\\\\n/g; s/\\r/\\\\r/g; s/\\"/\\\\\"/g' | sed 's/\"/\\"/g')

    curl_opts=(-s -w "%{http_code} %{time_total}")
    [[ -n "$COOKIE" ]] && curl_opts+=(-H "Cookie: $COOKIE")

    local REQUEST_URL="$URL?$PARAM=$payload"

    if [ "$METHOD" = "GET" ]; then
        RESPONSE=$(curl "${curl_opts[@]}" "$REQUEST_URL")
    else
        RESPONSE=$(curl "${curl_opts[@]}" -X POST "$URL" -d "$PARAM=$payload")
    fi

    RESPONSE_BODY=$(echo "$RESPONSE" | sed 's/ [0-9][0-9][0-9] \([0-9.]*\)$//')
    RESPONSE_CODE=$(echo "$RESPONSE" | awk '{print $(NF-1)}')
    RESPONSE_TIME=$(echo "$RESPONSE" | awk '{print $NF}')

    log "Testing $category payload: $display_payload" "INFO"
    log "Method: $METHOD" "INFO"
    log "Parameter: $PARAM" "INFO"
    log "Cookie: $COOKIE" "INFO"
    log "Request URL: $REQUEST_URL" "INFO"
    log "Response code: $RESPONSE_CODE" "INFO"

    if echo "$RESPONSE_BODY" | grep -qiE "(sql|syntax|error|mysql|oracle|postgresql)"; then
        log "Potential SQL error detected" "WARN"
        echo "$RESPONSE_BODY" | grep -iE "(sql|syntax|error|mysql|oracle|postgresql)" | tee -a "$LOG_FILE"
    fi

    if [[ "$category" =~ time-based && "$RESPONSE_CODE" -eq 200 ]]; then
        log "Time-based injection might be possible" "INFO"
        log "Response time: ${RESPONSE_TIME}s" "INFO"
    fi

    if [[ "$category" =~ union-based && "$RESPONSE_CODE" -eq 200 ]]; then
        log "Union-based injection might be possible" "INFO"
        echo "$RESPONSE_BODY" | grep -iE "(column|field|table)" | tee -a "$LOG_FILE"
    fi

    log "-" "INFO"
    log "Time: $(date '+%Y-%m-%d %H:%M:%S')" "INFO"

    sleep "$DELAY"
}

# Store start time
START_TS=$(date +%s)

# Main execution
log "Starting payload testing against $URL" "INFO"
log "Using parameter: $PARAM" "INFO"
log "Using HTTP method: $METHOD" "INFO"
log "Security level: $SECURITY" "INFO"
log "Results will be saved in: $OUTPUT_DIR" "INFO"
log "Cookie: $COOKIE" "INFO"
log "Delay between requests: $DELAY seconds" "INFO"
log "Start time: $(date '+%Y-%m-%d %H:%M:%S')" "INFO"
log "-" "INFO"

# Add test descriptions
log "\nTesting generic payloads..." "INFO"
log "Generic payloads test description:" "INFO"
log "    - Basic SQL injection tests" "INFO"
log "    - Simple quote-based injection" "INFO"
log "    - Basic union-based injection" "INFO"
log "    - Basic error-based injection" "INFO"
log "-" "INFO"

log "\nTesting blind SQLi payloads..." "INFO"
log "Blind SQLi test description:" "INFO"
log "    - Boolean-based injection" "INFO"
log "    - Conditional response tests" "INFO"
log "    - Data extraction techniques" "INFO"
log "-" "INFO"

log "\nTesting time-based payloads..." "INFO"
log "Time-based test description:" "INFO"
log "    - Sleep-based injection" "INFO"
log "    - Benchmark-based injection" "INFO"
log "    - Response time analysis" "INFO"
log "-" "INFO"

log "\nTesting error-based payloads..." "INFO"
log "Error-based test description:" "INFO"
log "    - Error triggering payloads" "INFO"
log "    - Error message analysis" "INFO"
log "    - Error-based data extraction" "INFO"
log "-" "INFO"

log "\nTesting union-based payloads..." "INFO"
log "Union-based test description:" "INFO"
log "    - Column count testing" "INFO"
log "    - Table information extraction" "INFO"
log "    - Data extraction techniques" "INFO"
log "-" "INFO"

log "\nTesting WAF bypass payloads..." "INFO"
log "WAF bypass test description:" "INFO"
log "    - Encoding techniques" "INFO"
log "    - Character replacement" "INFO"
log "    - Comment-based bypass" "INFO"
log "-" "INFO"

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD_DIR="$SCRIPT_DIR/../payloads"

# Process payloads
while IFS= read -r payload; do
    test_payload "$payload" "generic"
done < "$PAYLOAD_DIR/generic.txt"

while IFS= read -r payload; do
    test_payload "$payload" "blind"
done < "$PAYLOAD_DIR/blind.txt"

while IFS= read -r payload; do
    test_payload "$payload" "time-based"
done < "$PAYLOAD_DIR/time-based.txt"

while IFS= read -r payload; do
    test_payload "$payload" "error-based"
done < "$PAYLOAD_DIR/error-based.txt"

while IFS= read -r payload; do
    test_payload "$payload" "union-based"
done < "$PAYLOAD_DIR/union.txt"

while IFS= read -r payload; do
    test_payload "$payload" "waf_bypass"
done < "$PAYLOAD_DIR/waf_bypass.txt"

# Completion message
END_TS=$(date +%s)
DURATION=$((END_TS - START_TS))
echo "\n[+] Payload testing completed" | tee -a "$LOG_FILE"
echo "[+] End time: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "[+] Total duration: ${DURATION} seconds" | tee -a "$LOG_FILE"
echo "[+] Results saved in: $OUTPUT_DIR" | tee -a "$LOG_FILE"
echo "[+] Log file: $LOG_FILE" | tee -a "$LOG_FILE"
