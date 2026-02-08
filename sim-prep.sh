#!/bin/bash

:'
Description: 
  This shell script will prep a simulator for usage throughout the day by starting it off in a clean state. The basic overview of the code is:
    1. stop the sim and VFT
    2. clean the sim
    3. configure the sim and start VFT
'

:'
Notes:
- need to figure out xplane license key
- need to check IF iptables exists
'

set -o pipefail

#to log to journalctl
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

#verify sim-daemon is available
command -v sim-daemon >/dev/null 2>&1 || {
  echo "sim-daemon not found. Exiting."
  exit 1
}

#get sim status
SIM_STATUS=$(sim-daemon simulation status)
#get launcher status
LAUNCHER_STATUS="$(sim-daemon launcher status)"
ATTACH_PATH="/home/joby/attach_interfaces.sh"
IPTABLE_V1_PATH="/home/joby/iptables.sh"
IPTABLE_V2_PATH="/home/joby/iptablesv2.sh"

#stop sim if running if running
if echo "$SIM_STATUS" | grep -qi "RUNNING"; then
  log "Stopping sim..."
  sleep 3
  sim-daemon simulation stop
fi

#stop vft
log "Stopping VFT"
sleep 3
vft served stop

#wait for othe hosts to stop
sleep 20
log "Sim stopped"

#clean
log "Cleaning sim..."
sleep 3
sim-daemon simulation clean || exit 1

#wait for other hosts to clean
sleep 60
log "Sim Clean completed"

#configure
log "Configuring sim..."
sleep 3
sim-daemon simulation configure || exit 1

#wait for other hosts to configure
sleep 60

#attach interfaces/iptables
#--------------------------#
#check if attach script exists and run if it does
if [[ -f "$ATTACH_PATH" ]]; then
  log "Attaching interfaces"
  sleep 3
  "$ATTACH_PATH"
else
  log "No attach script found. Skipping..."
fi

#iptables based on SW version
if echo "$LAUNCHER_STATUS" | grep -Eq '(s4tc-1|s4tc-v1)'; then
  if [[ -f "$IPTABLE_V1_PATH" ]]; then
    log "Detected s4tc v1 launcher — configuring iptables for v1..."
    "$IPTABLE_V1_PATH"
  else
    log "iptables v1 script not found. Skipping..."
  fi
else
  if [[ -f "$IPTABLE_V2_PATH" ]]; then
    log "Detected s4tc v2 launcher — configuring iptables for v2..."
    "$IPTABLE_V2_PATH"
  else
    log "iptables v2 script not found. Skipping..."
  fi
fi



log "Sim configured"
sleep 10

#start VFT
log "Starting VFT"
sleep 3
vft served start -sim
