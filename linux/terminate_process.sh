log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2"
}


PROCESS_NAME=$1
PROCESS_ID=$2

#===Validating Input===
if [[ -z "$PROCESS_NAME" || -z "$PROCESS_ID" ]]; then
  log "ERROR" "Usage: $0 <process_name> <process_id>"
  exit 1
fi

#===Check sudo privileges===
if[["EUID" -ne 0]]; 
then
log "ERROR" "Please run as root (use sudo)"
exit 1 
fi

#===Terminate by process ID===
if [[ -n "$PROCESS_ID" ]]; then
  kill -9 "$PROCESS_ID" &> /dev/null
  if [[ $? -eq 0 ]]; then
    log "INFO" "Process $PROCESS_NAME ($PROCESS_ID) has been terminated"
  else
    log "ERROR" "Failed to terminate process $PROCESS_NAME ($PROCESS_ID)"
    exit 1
  fi
fi


#===Terminate by process name===
if [[ -n "$PROCESS_NAME" ]]; then
  pkill -f "$PROCESS_NAME" &> /dev/null
  if [[ $? -eq 0 ]]; then
    log "INFO" "Process $PROCESS_NAME has been terminated"
  else
    log "ERROR" "Failed to terminate process $PROCESS_NAME"
    exit 1
  fi
fi