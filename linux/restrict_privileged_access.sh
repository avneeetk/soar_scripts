log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2"
}

USERNAME=$1

#===Validating Input===
if [[ -z "$USERNAME" ]]; then
  log "ERROR" "Usage: $0 <username>"
  exit 1
fi

#===Check sudo privileges===
if [[ $EUID -ne 0 ]]; then
  log "ERROR" "Please run as root (use sudo)"
  exit 1
fi                  

#===Check if user exists===
if id "$USERNAME" &>/dev/null; then


#===Check if user is in sudo or wheel group===
    if id -nG "$USERNAME" | grep -qw "sudo" then
    gpasswd -d "$USERNAME" "sudo"
    log "INFO" "User $USERNAME has been removed from sudo group"
  elif id -nG "$USERNAME" | grep -qw "wheel"; then
    gpasswd -d "$USERNAME" "wheel"
    log "INFO" "User $USERNAME has been removed from wheel group"
  else
    log "INFO" "User $USERNAME is not in sudo or wheel group"
  fi
else
  log "ERROR" "User $USERNAME does not exist"
  exit 1
fi