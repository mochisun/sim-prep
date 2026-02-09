# sim-prep
**Overview:**  
This tool is created to prepare simulators for daily use by cleaning and reconfiguring to achieve a known-good state.
Designed to run on a periodic timer (M-F) and manually without requiring root privelages. 

**When Executed:**
1. Stops sim if running
2. Stops VFT
3. Cleans sim
4. Reconfigures sim
5. Starts VFT

**Repo contents:**  
sim-prep/  
├── sim-prep.sh # main sim prep script  
├── sim-prep.service # systemd user service (oneshot)  
├── sim-prep.timer # systemd timer  
├── sim-prep-installer.sh # installer script  
└── README.md # this file  

**How to Install:**  
1. Clone repo:
   - git clone <repo url> sim-prep
   - cd sim-prep
3. Run installer:
   - chmod +x sim-prep-installer.sh
   - ./sim-prep-installer.sh
Service and Timer will live here:  
~/.config/systemd/user/
Main script will live here:  
/home/joby/sim_prep/

**Manual Usage:**  
- run sim-prep: systemctl --user start sim-prep
- check status: systemctl --user status sim-prep
- view logs: journalctl --user -u sim-prep --no-pager

**To disable automated execution:**  
systemctl --user disable sim-prep.timer
systemctl --user stop sim-prep.timer
