log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2"
}

USERNAME=$1
NEW_PASSWORD=$2

#===Validating Input===
if [[-z "$USERNAME" || -z "NEW_PASSWORD"]]; 
then 
log "ERROR" "Usage: $0 <username><new_password>"
exit 1
fi

#===Check sudo privileges===
if[["EUID" -ne 0]]; 
then
log "ERROR" "Please run as root (use sudo)"
exit 1 
fi

#===Check if user exists===
if id "$USERNAME" &>/dev/null;  
then 
echo "$USERNAME:$NEW_PASSWORD"| chpasswd

if [[$? -eq 0 ]]; 
then
log "INFO" "Password successfully changed for user $USERNAME"
else
log "ERROR" "Password change failed"
exit 1
fi
else 
log "ERROR" "User $USERNAME does not exist
exit 1
fi