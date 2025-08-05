log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$1] $2"
}

METHOD=$1


#===Check if running as root===
if [[ $EUID -ne 0 ]]; then
  log "ERROR" "Please run as root (use sudo)"
  exit 1
fi

if[[ -z "$METHOD" ]]; then
  log "ERROR" "Usage: $0 <FTP|SMB>"
  exit 1
fi

#===Check for IP Tables===
if ! command -v iptables &> /dev/null; then
  log "ERROR" "iptables is not installed. Please install it first using your package manager."
  exit 1
fi
#===Block FTP or SMB based on the method===
if [[ "$METHOD" == "FTP" ]]; then
  iptables -A INPUT -p tcp --dport 21 -j DROP
  if [[ $? -eq 0 ]]; then
    log "INFO" "FTP has been successfully blocked"
  else
    log "ERROR" "Failed to block FTP"
    exit 1
  fi
elif [[ "$METHOD" == "SMB" ]]; then
  iptables -A INPUT -p tcp --dport 445 -j DROP
  if [[ $? -eq 0 ]]; then           
    log "INFO" "SMB has been successfully blocked"
  else
    log "ERROR" "Failed to block SMB"
    exit 1
  fi
else
  log "ERROR" "Invalid method. Use 'FTP' or 'SMB'."
  exit 1
fi      
