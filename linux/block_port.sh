log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$1] $2"
}

PORT=$1
PROTOCOL=$2

#===Validating Input===
if [[ -z "$PORT" || -z "$PROTOCOL" ]]; then
  log "ERROR" "Usage: $0 <port_number> <tcp|udp>"
  exit 1
fi

#===Check if port is a number===
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
  log "ERROR" "Port must be a number between 1 and 65535"
  exit 1
fi

#====Check if protocol is valid===
if [[ "$PROTOCOL" != "tcp" && "$PROTOCOL" != "udp" ]]; then
  log "ERROR" "Protocol must be either 'tcp' or 'udp'"
  exit 1
fi

#===Check if running as root===
if [[ $EUID -ne 0 ]]; then
  log "ERROR" "Please run as root (use sudo)"
  exit 1
fi

#===Check if IP tables is installed===
if ! command -v iptables &> /dev/null; then
  log "ERROR" "iptables is not installed. Please install it first using your package manager."
  exit 1
fi

#===Block the port===
iptables -A INPUT -p "$PROTOCOL" --dport "$PORT" 
-j DROP
if [[ $? -eq 0 ]]; then
  log "INFO" "Port $PORT ($PROTOCOL) has been successfully blocked"
else
  log "ERROR" "Failed to block port $PORT ($PROTOCOL)"
  exit 1
fi