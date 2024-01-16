#!/bin/bash

TARGET_IP=$1

if [ -z "$TARGET_IP" ]; then
    echo "Please provide target IP as first argument"
    exit 1
fi

addForward() {
    local localPort=$1
    local ip=$2
    local remotePort=$3

    iptables -t nat -A PREROUTING -p tcp --dport $localPort -j DNAT --to-destination $ip:$remotePort
}

# add forwarding rules for targetIp
addForward 80 $TARGET_IP 80
addForward 443 $TARGET_IP 443

# apply NAT
iptables -t nat -A POSTROUTING -j MASQUERADE

# enable ip forwarding
sysctl -w net.ipv4.ip_forward=1
