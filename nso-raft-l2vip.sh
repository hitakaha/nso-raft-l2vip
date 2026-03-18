#!/bin/sh
# -----------------------------------------------------------------------------
# Script: manage_nso_vip.sh
# Description: Manages a Layer 2 Virtual IP (VIP) for Cisco NSO RAFT clusters.
#              Uses RESTCONF to determine HA status.
# -----------------------------------------------------------------------------

# --- Configuration ---
NIC=ens160
VIP=198.18.134.210
MASK=18
# NSO RESTCONF details
NSO_PORT="8080"
USERNAME="admin"
PASSWORD="admin"

# --- Role Check ---
# Query NSO via RESTCONF to determine the current HA RAFT role.
# We use -s for silent mode and -k to ignore SSL errors (if using self-signed certs).
ROLE=$(curl -s -k -u "$USERNAME":"$PASSWORD" \
  "http://localhost:$NSO_PORT/restconf/data/tailf-ncs-high-availability-raft:ha-raft/status/role" \
  -H "Accept: application/yang-data+json" | jq -r '."tailf-ncs-high-availability-raft:role"')

# Check if the API call succeeded and if the role is "leader"
if [ "$?" -eq 0 ] && [ "$ROLE" == "leader" ]; then
    
    # --- Leader Logic ---
    if ip addr show dev "$NIC" | grep -q "$VIP"; then
        echo "Status: Node is leader. VIP $VIP is already active."
    else
        echo "Status: Node is leader but VIP $VIP is not assigned. Configuring..."
        ip addr add "$VIP/$MASK" dev "$NIC"
        arping -U -c 3 -I "$NIC" "$VIP"
        echo "Success: VIP $VIP assigned and Gratuitous ARP sent."
    fi
else
    # --- Non-Leader Logic ---
    echo "Status: Node is not the leader or NSO service is unreachable (Role: $ROLE)."
    
    if ip addr show dev "$NIC" | grep -q "$VIP"; then
        echo "Action: VIP $VIP detected on a non-leader node. Removing..."
        ip addr del "$VIP/$MASK" dev "$NIC"
        echo "Success: VIP $VIP has been removed."
    fi
fi
