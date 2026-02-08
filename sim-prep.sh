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

#get sim status
SIM_STATUS=$(sim-daemon simulation status)
#get launcher status
LAUNCHER_STATUS="$(sim-daemon launcher status)"
ATTACH_PATH="/home/joby/attach_interfaces.sh"
IPTABLE_PATH="/home/joby/iptables.sh

#stop sim if running if running
if echo "$SIM_STATUS" | grep "RUNNING"; then
  echo "Stopping sim..."
  sleep 3
  sim-daemon simulation stop
fi

#stop vft
echo "Stopping VFT"
sleep 3
vft served stop

#wait for othe hosts to stop
sleep 20
echo "Sim stopped"

#clean
echo "Cleaning sim..."
sleep 3
sim-daemon simulation clean

#wait for other hosts to clean
sleep 60
echo "Sim Clean completed"

#configure
echo "Configuring sim..."
sleep 3
sim-daemon simulation configure

#wait for other hosts to configure
sleep 60

#attach interfaces/iptables
#--------------------------#
#check if attach script exists and run if it does
if [[ -f "$ATTACH_PATH" ]]; then
  echo "Attaching interfaces"
  sleep 3
  /home/joby/attach_interfaces.sh
else
  echo "No attach script found. Skipping..."
fi

#check if iptables script exist and then run based on SW version
if [[ -f "IPTABLE_PATH" ]]; then
  echo "Setting up iptables"
  sleep 3
  #if V1 SW ->
  if echo "$LAUNCHER_STATUS" | grep -Eq '(s4tc-1|s4tc-v1)'; then
    echo "Detected s4tc v1 launcher — configuring iptables for v1..."
    /home/joby/iptables.sh
  else
    echo "Detected s4tc v2 launcher — configuring iptables for v2..."
    /home/joby/iptablesv2.sh
  fi
else
  echo "No iptables script found. Skipping..."
fi

echo "Sim configured"
sleep 10

#start VFT
echo "Starting VFT"
sleep 3
vft served start -sim
