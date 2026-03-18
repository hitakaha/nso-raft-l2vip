To improve the clarity and conciseness of your documentation, I have refined the structure, corrected typos, and streamlined the instructions while maintaining the technical integrity of the configuration.

# Configure L2 Virtual IP (VIP) for NSO RAFT Clusters

This script automates the configuration of a Layer 2 Virtual IP (VIP) for Cisco NSO (Network Services Orchestrator) RAFT-based high availability clusters, ensuring traffic is directed to the current leader node.

## Prerequisites

Ensure the following dependencies are installed on the target host:

*   **System Utilities**: `arping`, `curl`, and `jq` (e.g., `sudo apt install arping curl jq` or `sudo yum install iputils curl jq`).
*   **NSO Installation**: NSO must be installed as a `system-install` to ensure proper service management and permissions.
*   **RESTCONF**: RESTCONF must be enabled and accessible via `localhost`.
*   **Permissions**: The user executing the script requires sufficient privileges to run `arping` and interact with the NSO CLI.

## Setup

### 1. Clone the Repository
```bash
git clone https://github.com/hitakaha/nso-raft-l2vip.git
```

### 2. Configure Credentials
Update the credentials in `nso-raft-l2vip.sh`:

```bash
# NSO RESTCONF details
NSO_PORT="8080"
USERNAME="admin"
PASSWORD="admin"
```

## Pre-check

Verify the environment before scheduling the script:

1. **Confirm RESTCONF access**:
   ```bash
   curl -u <username>:<password> http://localhost:8080/restconf/data/tailf-ncs-high-availability-raft:ha-raft/status/role -H "Accept: application/yang-data+json"
   ```

2. **Verify RAFT state**:
   ```bash
   curl -u <username>:<password> http://localhost:8080/restconf/data/tailf-ncs-high-availability-raft:ha-raft/status/role -H "Accept: application/yang-data+json" | jq -r '."tailf-ncs-high-availability-raft:role"'
   ```

3. **Test script execution**:
   ```bash
   bash nso-raft-l2vip/nso-raft-l2vip.sh
   # Expected output: leader or follower
   ```

## Scheduling the Script

### Method 1: Systemd Timers (Recommended)
Systemd is the preferred method for modern Linux distributions due to superior logging and resource management.

**1. Create the Service File** (`/etc/systemd/system/nso-vip.service`):
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

**2. Create the Timer File** (`/etc/systemd/system/nso-vip.timer`):
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

**3. Enable and Start**:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now nso-vip.timer
```

---

### Method 2: Traditional Cron
If your environment requires `cron`, add the task to the root crontab.

**1. Configure Crontab**:
```bash
sudo crontab -e
```

**2. Add Schedule**:
To run every 5 seconds, add the following entries:
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

## Verification

Ensure the script is executable:
```bash
sudo chmod +x /root/nso-raft-l2vip/nso-raft-l2vip.sh
```

**Check status and logs**:
*   **Systemd**: `systemctl list-timers --all | grep nso-vip` and `journalctl -u nso-vip.service -f`
*   **Cron**: `grep CRON /var/log/syslog`  
 
