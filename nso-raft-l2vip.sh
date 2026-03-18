#!/bin/sh
# Configure L2 VIP for NSO RAFT servers
# Prerequisites:
# - install arping
# - install NSO as system-install
#
# How to use:
# - Schedule this script to run, say every 5 sec, by cron
#   following is example
#
NIC=ens160         # Interface to configure the VIP
VIP=198.18.134.210 # Virtual IP for the RAFT cluster
MASK=18            # network mask length

# Capture the output of the ncs_cli command
OUTPUT=$(ncs_cli -u admin << EOF
switch cli
show ha-raft | include role
exit
EOF
)

# Check if the command succeeded and output contains "leader"
if [ $? -eq 0 ] && echo "$OUTPUT" | grep -q "leader"; then
    echo "Node is leader. Configuring VIP..."
    
    # Assign the VIP to the interface (assuming a /24 subnet, adjust as needed)
    ip addr add $VIP/$MASK dev $NIC
    
    # Send gratuitous ARP to update network switches
    # -U: Unsolicited ARP, -c 3: send 3 packets, -I: interface
    arping -U -c 3 -I $NIC $VIP
    
    echo "VIP $VIP configured and gratuitous ARP sent."
else
    echo "Node is not leader or command failed. No action taken."
fi
