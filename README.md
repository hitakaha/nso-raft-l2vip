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
   * * * * * /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 5; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 10; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 15; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 20; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 25; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 30; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 35; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 40; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 45; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 50; /usr/bin/python3 /path/to/your/script.py
   * * * * * sleep 55; /usr/bin/python3 /path/to/your/script.py
