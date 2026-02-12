#!/bin/bash

: <<'EOF'
Description: This script is used to print the currently running battery preset
        1. Get running sim-preset name off launcher status
        2. Navigate to the custom preset
        3. Determine battery type (p56/p57)
        4. Print the result
EOF

#get the preset name from the launcher status
#using awk to search for line containing 'Preset' and then printing the 4th column of that line:
SIM_PRESET_NAME=$(sim-daemon launcher status | awk '/Preset/ {print $4}')

#2 different custom-preset paths:
V1_PATH="/home/joby/.config/sim-daemon/custom-presets/2p1/"
V2_PATH="/var/lib/sim-daemon/launcher_volume/custom_presets_v2/2p1/"


#check if exists in custom presets:
if [ -f "$V1_PATH""$SIM_PRESET_NAME" ]; then
  echo "Found V1 preset. Determining battery type..."
  SIM_PRESET_FILE=$V1_PATH$SIM_PRESET_NAME

elif [ -f "$V2_PATH$""$SIM_PRESET_NAME" ]; then
  echo "Found V2 preset. Determining battery type..."
  SIM_PRESET_FILE=$V2_PATH$SIM_PRESET_NAME

else
  echo "Preset not found in custom presets. Unable to determine battery type"
fi


echo $SIM_PRESET_FILE


FARASIS=$(awk '/farasis_rev/ {print $0}' ${SIM_PRESET_fILE})

"sim_components": {
        "aileron_2p1_1": {
            "is_disabled": true
        },
        "aileron_2p1_2": {
            "is_disabled": true
        }
        "bms_2p1_farasis_rev2_2": {
            "is_disabled": true
        },
        "bms_2p1_farasis_rev2_3": {
            "is_disabled": true
        }
}
