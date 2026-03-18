# Configure L2 Virtual IP (VIP) for NSO RAFT Clusters

This script automates the configuration of a Layer 2 Virtual IP (VIP) for Cisco NSO (Network Services Orchestrator) RAFT-based high availability clusters. It ensures that traffic is directed to the current leader node.

# Prerequisites

Ensure the following dependencies are met on the target host:

* **System Utility**: `arping` must be installed (e.g., `sudo apt install arping` or `sudo yum install iputils`).
* **NSO Installation**: NSO must be installed as a `system-install` to ensure proper service management and permissions.
* **Permissions**: The user executing the script must have sufficient privileges to execute `arping` and interact with the NSO CLI.

# How to Use

## NSO Raft L2 VIP Scheduling on Ubuntu 25.04

This guide provides two methods to execute the `/root/nso-raft-l2vip/nso-raft-l2vip.sh` script every 5 seconds on Ubuntu 25.04.

## Method 1: Systemd Timers (Recommended)
Systemd is the native scheduler for Ubuntu 25.04 and is preferred for its robust logging and resource management.

### 1. Create the Service File
Create `/etc/systemd/system/nso-vip.service`:
```ini
[Unit]
Description=Cisco NSO Raft L2 VIP Management Script
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
User=root

[Install]
WantedBy=multi-user.target
```

### 2. Create the Timer File
Create `/etc/systemd/system/nso-vip.timer`:
```ini
[Unit]
Description=Run NSO VIP script every 5 seconds

[Timer]
OnBootSec=5s
OnUnitActiveSec=5s
AccuracySec=1s

[Install]
WantedBy=timers.target
```

### 3. Enable and Start
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now nso-vip.timer
```

---

## Method 2: Traditional Cron
If your environment requires the traditional `crontab` syntax, ensure `cron` is installed.

### 1. Install and Enable Cron
```bash
sudo apt update
sudo apt install cron -y
sudo systemctl enable --now cron
```

### 2. Configure Crontab
Open the root crontab:
```bash
sudo crontab -e
```

### 3. Add the Schedule
Add the following lines to the end of the file:
```text
* * * * * bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 5; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 10; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 15; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 20; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 25; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 30; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 35; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 40; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 45; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 50; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
* * * * * sleep 55; bash /root/nso-raft-l2vip/nso-raft-l2vip.sh
```

---

## Verification
Ensure the script is executable:
```bash
sudo chmod +x /root/nso-raft-l2vip/nso-raft-l2vip.sh
```

**Check Systemd status:**
```bash
systemctl list-timers --all | grep nso-vip
```

**View logs:**
```bash
# For Systemd
journalctl -u nso-vip.service -f

# For Cron
grep CRON /var/log/syslog
```  
 





