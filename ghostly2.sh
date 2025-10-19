#!/bin/bash

# Ghostly v1 - Advanced Stealth Fuzzer
#  by 0xTa7on, merged with features from another tools.
# A tool designed to perform web content discovery while minimizing detection .

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Default Headers & User Agents ---
DEFAULT_USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:107.0) Gecko/20100101 Firefox/107.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"
)
ACCEPT_LANGUAGES=( "en-US,en;q=0.9" "fr-CH,fr;q=0.9,en;q=0.8" "de-DE,de;q=0.9,en-US;q=0.8" "es-ES,es;q=0.9" )
REFERERS=( "https://www.google.com/" "https://www.bing.com/" "https://duckduckgo.com/" "https://www.yahoo.com/" )

# --- Default values ---
URL=""
WORDLIST=""
DELAY="0"
USER_AGENTS_FILE=""
THREADS=10 # A more aggressive default for speed
PROXY=""
PROXY_FILE=""
EXTENSIONS=""
USE_TOR=false
TOR_PROXY_ADDR="127.0.0.1:9050"


# --- Function to display help message ---
function show_help() {
    echo -e "${CYAN}Ghostly v1 - Advanced Stealth Fuzzer by 0xTa7on${NC}"
    echo "A tool designed to perform web content discovery while minimizing detection."
    echo ""
    echo "Usage: $0 -u <URL> -w <WORDLIST> [OPTIONS]"
    echo ""
    echo "Required Arguments:"
    echo "  -u <URL>         Target URL (e.g., http://example.com/FUZZ)"
    echo "  -w <WORDLIST>    Path to the wordlist file"
    echo ""
    echo "Options:"
    echo "  -t <THREADS>     Number of parallel threads (default: 10)"
    echo "  -d <DELAY>       Random delay between requests. Examples: '2' (0-2s), '1-3' (1-3s). Default: '0'"
    echo "  -x <EXTS>        Comma-separated extensions to append (e.g., .php,.html,.bak)"
    echo "  -a <USER_AGENTS> Path to a file containing user agents (one per line)"
    echo "  -p <PROXY>       Single proxy to use (e.g., http://127.0.0.1:8080)"
    echo "  -P <PROXY_FILE>  Path to a file containing a list of proxies"
    echo "  --tor            Enable Tor proxy via default address (127.0.0.1:9050)"
    echo "  --tor-proxy <ADDR> Specify a custom Tor proxy address (e.g., 127.0.0.1:9150). Implies --tor."
    echo "  -h               Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -u http://example.com/FUZZ -w common.txt -t 20 -x .php,.html"
    echo ""
}

# --- Function to display banner ---
function show_banner() {
    echo -e "${PURPLE}"
    echo "  ____ _              _   _     _   "
    echo " / ___| |__   ___  ___| |_| |__ | | v1"
    echo "| | _| '_ \ / _ \/ __| __| '_ \| |"
    echo "| |_| | | | | (_) \__ \ |_| | | | |"
    echo " \____|_| |_|\___||___/\__|_| |_|_|"
    echo -e "      ${CYAN}""eyes on you like a knife"" by 0xTa7on${NC}"
    echo -e "${NC}"
}

# --- Argument Parser (from v, more robust) ---
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -u) URL="$2"; shift; shift ;;
        -w) WORDLIST="$2"; shift; shift ;;
        -d) DELAY="$2"; shift; shift ;;
        -a) USER_AGENTS_FILE="$2"; shift; shift ;;
        -t) THREADS="$2"; shift; shift ;;
        -p) PROXY="$2"; shift; shift ;;
        -P) PROXY_FILE="$2"; shift; shift ;;
        -x) EXTENSIONS="$2"; shift; shift ;;
        --tor) USE_TOR=true; shift ;;
        --tor-proxy) TOR_PROXY_ADDR="$2"; USE_TOR=true; shift; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

# --- Configure Tor Proxy ---
if [ "$USE_TOR" = true ]; then
    PROXY="socks5h://$TOR_PROXY_ADDR"
fi

# --- Validate required arguments and inputs ---
if [ -z "$URL" ] || [ -z "$WORDLIST" ]; then
    echo -e "${RED}Error: Target URL (-u) and Wordlist (-w) are required.${NC}"
    show_help
    exit 1
fi
if [[ "$URL" != *FUZZ* ]]; then
    echo -e "${RED}Error: The URL must contain 'FUZZ' as a placeholder.${NC}"
    exit 1
fi
if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}Error: Wordlist file not found at '$WORDLIST'${NC}"
    exit 1
fi

# --- Validate numerical inputs ---
if ! [[ "$THREADS" =~ ^[0-9]+$ ]] || [ "$THREADS" -lt 1 ]; then
    echo -e "${RED}Error: Threads (-t) must be a positive integer.${NC}" >&2
    exit 1
fi

# --- Parse and Validate Delay ---
MIN_DELAY=0
MAX_DELAY=0
delay_regex='^[0-9]+([.][0-9]+)?$'
if [[ $DELAY == *-* ]]; then
    MIN_DELAY=$(echo "$DELAY" | cut -d'-' -f1)
    MAX_DELAY=$(echo "$DELAY" | cut -d'-' -f2)
    if ! [[ $MIN_DELAY =~ $delay_regex ]] || ! [[ $MAX_DELAY =~ $delay_regex ]]; then
        echo -e "${RED}Error: Delay (-d) range must contain valid numbers.${NC}" >&2
        exit 1
    fi
    # Use awk for floating point comparison to see if min > max
    if (( $(awk -v min="$MIN_DELAY" -v max="$MAX_DELAY" 'BEGIN {print (min > max)}') )); then
        echo -e "${RED}Error: In delay range '$DELAY', min delay cannot be greater than max delay.${NC}" >&2
        exit 1
    fi
else
    if ! [[ $DELAY =~ $delay_regex ]]; then
        echo -e "${RED}Error: Delay (-d) must be a valid number.${NC}" >&2
        exit 1
    fi
    MAX_DELAY=$DELAY
fi

# --- Load User Agents ---
if [ -n "$USER_AGENTS_FILE" ] && [ -f "$USER_AGENTS_FILE" ]; then
    mapfile -t USER_AGENTS < "$USER_AGENTS_FILE"
else
    USER_AGENTS=("${DEFAULT_USER_AGENTS[@]}")
fi
# Safety fallback
if [ ${#USER_AGENTS[@]} -eq 0 ]; then
    USER_AGENTS=("${DEFAULT_USER_AGENTS[0]}")
fi

# --- Load Proxies ---
if [ -n "$PROXY_FILE" ] && [ -f "$PROXY_FILE" ]; then
    mapfile -t PROXIES < "$PROXY_FILE"
fi

# --- Parse Extensions ---
IFS=',' read -r -a EXT_ARRAY <<< "$EXTENSIONS"

# --- Fuzzing Function ---
# This function is exported to be used by xargs for parallel processing.
# It performs a SINGLE, efficient request per entry.
perform_scan() {
    local entry=$1

    # Select a proxy
    local current_proxy="$PROXY"
    if [ ${#PROXIES[@]} -gt 0 ]; then
        current_proxy=${PROXIES[$RANDOM % ${#PROXIES[@]}]}
    fi

    # Select random headers with safety fallbacks to prevent division-by-zero
    local random_ua
    if [ ${#USER_AGENTS[@]} -gt 0 ]; then
        random_ua=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}
    else # Fallback in case array isn't exported correctly
        random_ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
    fi

    local random_lang
    if [ ${#ACCEPT_LANGUAGES[@]} -gt 0 ]; then
        random_lang=${ACCEPT_LANGUAGES[$RANDOM % ${#ACCEPT_LANGUAGES[@]}]}
    else # Fallback
        random_lang="en-US,en;q=0.9"
    fi

    local random_ref
    if [ ${#REFERERS[@]} -gt 0 ]; then
        random_ref=${REFERERS[$RANDOM % ${#REFERERS[@]}]}
    else # Fallback
        random_ref="https://www.google.com/"
    fi

    # Construct curl command
    local target_url="${URL//FUZZ/$entry}"
    local curl_opts=(-s -o /dev/null -w "%{http_code}" --connect-timeout 10 -L)
    [ -n "$current_proxy" ] && curl_opts+=(-x "$current_proxy")

    local status_code=$(curl "${curl_opts[@]}" \
        -H "User-Agent: $random_ua" \
        -H "Accept-Language: $random_lang" \
        -H "Referer: $random_ref" \
        "$target_url")

    # Color code the output
    local color=$NC
    if (( status_code >= 200 && status_code < 300 )); then color=$GREEN
    elif (( status_code >= 300 && status_code < 400 )); then color=$BLUE
    elif (( status_code >= 400 && status_code < 500 )); then color=$YELLOW
    elif (( status_code >= 500 )); then color=$RED
    fi

    # Print if not 404 or 000 (error)
    if [ "$status_code" != "404" ] && [ "$status_code" != "000" ]; then
        # Use printf for safer output handling
        printf "${color}[%s]${NC}\t| %s\n" "$status_code" "$target_url"
    fi

    # Apply delay if specified
    if [[ $(awk -v val="$MAX_DELAY" 'BEGIN {print (val > 0)}') == "1" ]]; then
        sleep "$(awk -v min="$MIN_DELAY" -v max="$MAX_DELAY" 'BEGIN{srand(); print min+rand()*(max-min)}')"
    fi
}
# Export the function and all required variables for xargs
export -f perform_scan
export URL USER_AGENTS ACCEPT_LANGUAGES REFERERS PROXIES PROXY MIN_DELAY MAX_DELAY

# --- Show Banner ---
show_banner

# --- Main Fuzzing Logic ---
echo -e "${BLUE}[*] Target: $URL${NC}"
echo -e "${BLUE}[*] Wordlist: $WORDLIST${NC}"
echo -e "${BLUE}[*] Threads: $THREADS${NC}"
[ -n "$EXTENSIONS" ] && echo -e "${BLUE}[*] Extensions: $EXTENSIONS${NC}"
[ -n "$PROXY" ] && echo -e "${BLUE}[*] Proxy: $PROXY${NC}"
[ -n "$PROXY_FILE" ] && echo -e "${BLUE}[*] Proxy List: $PROXY_FILE${NC}"
echo "----------------------------------------------------"
echo -e "${YELLOW}STATUS  | URL${NC}"
echo "----------------------------------------------------"

# Create a temporary file to hold the final wordlist with extensions
TEMP_WORDLIST=$(mktemp)
# Ensure the temp file is removed on exit
trap 'rm -f "$TEMP_WORDLIST"' EXIT

# Generate the final wordlist with extensions applied
if [ ${#EXT_ARRAY[@]} -gt 0 ] && [ -n "${EXT_ARRAY[0]}" ]; then
    while IFS= read -r entry; do
        echo "$entry" >> "$TEMP_WORDLIST"
        for ext in "${EXT_ARRAY[@]}"; do
            echo "$entry$ext" >> "$TEMP_WORDLIST"
        done
    done < "$WORDLIST"
else
    # If no extensions, just use the original wordlist
    cat "$WORDLIST" > "$TEMP_WORDLIST"
fi


# Execute in parallel or sequentially based on THREADS
if [ "$THREADS" -le 1 ]; then
    # Sequential mode for a single thread
    while IFS= read -r entry; do
        perform_scan "$entry"
    done < "$TEMP_WORDLIST"
else
    # Parallel mode for multiple threads
    cat "$TEMP_WORDLIST" | xargs -I {} -P "$THREADS" bash -c 'perform_scan "{}"'
fi


echo "----------------------------------------------------"
echo -e "${GREEN}[*] Scan complete.${NC}"

