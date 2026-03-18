# Configure L2 Virtual IP (VIP) for NSO RAFT Clusters

This script automates the configuration of a Layer 2 Virtual IP (VIP) for Cisco NSO (Network Services Orchestrator) RAFT-based high availability clusters. It ensures that traffic is directed to the current leader node.

## Prerequisites

Ensure the following dependencies are met on the target host:

* **System Utility**: `arping` must be installed (e.g., `sudo apt install arping` or `sudo yum install iputils`).
* **NSO Installation**: NSO must be installed as a `system-install` to ensure proper service management and permissions.
* **Permissions**: The user executing the script must have sufficient privileges to execute `arping` and interact with the NSO CLI.

## How to Use

To maintain high availability, schedule this script to run periodically (e.g., every 5 seconds) using `cron`.

### Scheduling via Cron
1. Open your crontab configuration:
   `crontab -e`

2. Add the following entry to execute the script every 5 seconds:
   ```cron
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
   



