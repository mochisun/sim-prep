#!/bin/bash
:'
Description: Script to install all the sim preparation tool to include:
  1. sim-prep.sh: executable script
  2. sim-prep.service: service for the tool
  3. sim-prep.timer: timer to make the service periodic
'
set -o pipefail

USER=$(whoami)

SERVICE_NAME="sim-prep.service"
TIMER_NAME="sim-prep.timer"

INSTALL_DIR="$HOME/sim_prep"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

SCRIPT_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#log for journalctl functionality
log(){
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}
#error handling
error() {
  echo "ERROR: $1" >&2
  exit 1
}

# Check if running as root (we don't want this)
if [ "$EUID" -eq 0 ]; then
    error "This script should NOT be run as root. Please run as a regular user."
fi

#verify systemctl and sim-daemon are available
command -v systemctl >/dev/null 2>&1 || error "systemctl not found"
command -v sim-daemon >/dev/null 2>&1 || error "sim-daemon not found"

log "Starting sim-prep installation for user: $USER"

log "Creating install directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$SYSTEMD_USER_DIR"

#instal main script
log "Installing sim-prep.sh..."
cp "$SCRIPT_SOURCE_DIR/sim-prep.sh" "$INSTALL_DIR"
log "Making script executable..."
chmod +x "$INSTALL_DIR/sim-prep.sh"

#install service
log "Installing systemd service..."
cp "$SCRIPT_SOURCE_DIR/$SERVICE_NAME" "$SYSTEMD_USER_DIR"

#install timer
log "Installing systemd timer..."
cp "$SCRIPT_SOURCE_DIR/$TIMER_NAME" "$SYSTEMD_USER_DIR"

#reload systemd
log "Reloading systemd..."
systemctl --user daemon-reload

#enable timer
log "Enabling sim-prep timer..."
systemctl --user enable "$TIMER_NAME"

log "Installation of sim-prep tool complete!"

log "Installation completed successfully!"
echo ""
echo "=== Installation Summary ==="
echo "✓ User: $USER"
echo "✓ User systemd service: $SERVICE_NAME"
echo "• Service files are stored in: $SYSTEMD_USER_DIR"
echo "• Service is scheduled via systemd timer"
echo "• To run sim-prep manually: systemctl --user start $SERVICE_NAME"
echo "• To view timer status: systemctl --user list-timers"
echo "• To disable schedule: systemctl --user disable $TIMER_NAME"
echo "• To view logs: journalctl --user -u $SERVICE_NAME"
echo ""







