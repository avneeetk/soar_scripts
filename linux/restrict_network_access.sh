log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2"
}

TARGET_IP=$1
DIRECTION=$2

if[["$EUID" -ne 0]]; then
  log "ERROR" "Please run as root (use sudo)"
  exit 1
fi  

#===Check sudo privileges===
if [[ "$EUID" -ne 0 ]]; then
  log "ERROR" "Please run as root (use sudo)"
  exit 1
fi

#===Check for IP Tables===
if ! command -v iptables &> /dev/null; then
  log "ERROR" "iptables is not installed. Please install it first using your package manager."
  exit 1
fi  

#===Block network access===
if [[ -z "$TARGET_IP"  ]]; then
  log "INFO" "Blocking all inbound and outbound network traffic"
    iptables -A INPUT -j DROP
    iptables -A OUTPUT -j DROP
    exit 0
fi

#===Block specific IP address===
if [[ "$DIRECTION" == "Inbound" ]]; then
  iptables -A INPUT -s "$TARGET_IP" -j DROP
  log "INFO" "Blocked inbound traffic from $TARGET_IP"
elif [[ "$DIRECTION" == "Outbound" ]]; then
  iptables -A OUTPUT -d "$TARGET_IP" -j DROP
  log "INFO" "Blocked outbound traffic to $TARGET_IP"
else
  log "ERROR" "Invalid direction specified. Use 'Inbound' or 'Outbound'."
  exit 1
fi