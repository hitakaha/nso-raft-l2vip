#!/bin/sh
# -----------------------------------------------------------------------------
# Script: manage_nso_vip.sh
# Description: Manages a Layer 2 Virtual IP (VIP) for Cisco NSO RAFT clusters.
#              - If the node is the RAFT leader, it ensures the VIP is assigned.
#              - If the node is NOT the leader, it ensures the VIP is removed.
#
# Prerequisites:
# - 'arping' utility must be installed.
# - NSO must be installed as a system-install.
#
# Usage: Schedule this script to run via cron (e.g., every 5 seconds).
# -----------------------------------------------------------------------------

# --- Configuration ---
NIC=ens160         # Network interface where the VIP will be managed
VIP=198.18.134.210 # Virtual IP address for the RAFT cluster
MASK=18            # Subnet mask length (CIDR notation)

# --- Role Check ---
# Query NSO CLI to determine the current HA RAFT role.
OUTPUT=$(ncs_cli -u admin << EOF
switch cli
show ha-raft | include role
exit
EOF
)

# Check if the CLI command succeeded and if the output identifies this node as the leader.
if [ $? -eq 0 ] && echo "$OUTPUT" | grep -q "leader"; then
    
    # --- Leader Logic ---
    # Check if the VIP is already assigned to avoid redundant configuration.
    if ip addr show dev "$NIC" | grep -q "$VIP"; then
        echo "Status: Node is leader. VIP $VIP is already active. No action taken."
    else
        echo "Status: Node is leader but VIP $VIP is not assigned. Configuring..."
        
        # Assign the VIP to the interface.
        ip addr add "$VIP/$MASK" dev "$NIC"
        
        # Send Gratuitous ARP (GARP) packets to update the ARP tables of neighboring switches.
        # -U: Unsolicited ARP mode, -c 3: Send 3 packets, -I: Specify interface.
        arping -U -c 3 -I "$NIC" "$VIP"
        
        echo "Success: VIP $VIP assigned and Gratuitous ARP sent."
    fi
else
    # --- Non-Leader Logic ---
    # If the node is not the leader (or NSO is down), ensure the VIP is not active on this host.
    echo "Status: Node is not the leader or NSO service is unreachable."
    
    if ip addr show dev "$NIC" | grep -q "$VIP"; then
        echo "Action: VIP $VIP detected on a non-leader node. Removing VIP to prevent IP conflict..."
        ip addr del "$VIP/$MASK" dev "$NIC"
        echo "Success: VIP $VIP has been removed."
    else
        echo "Status: VIP $VIP is not present. No cleanup required."
    fi
fi
