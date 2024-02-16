#!/bin/bash

if [ "$EUID" -ne 0 ]
    then echo "This script must be run as root"
    exit
fi

saveIptables() {
    netfilter-persistent save
}

installIptablesPersistent() {
    apt install iptables-persistent
}

manageForward() {
    # -A: append a rule
    # -D: delete a rule
    local operation=$1

    read -p "Enter protocol (tcp/udp): " protocol
    read -p "Enter local port: " localPort
    read -p "Enter remote ip: " ip
    read -p "Enter remote port: " remotePort

    iptables -t nat $operation PREROUTING -p $protocol --dport $localPort -j DNAT --to-destination $ip:$remotePort
    iptables -t nat -A POSTROUTING -j MASQUERADE
}

listForward() {
    iptables -t nat -L PREROUTING
}

enableIpForwarding() {
    isIpForwardingEnabled=$(cat /proc/sys/net/ipv4/ip_forward)

    if [ $isIpForwardingEnabled -eq 1 ]
    then
        echo "IP forwarding is already enabled"
        return
    fi

    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    sysctl -p
    sysctl --system

    echo "IP forwarding has been enabled"
}

title="Hello! This is a script manage port forwarding using iptables"
title=""
prompt="Pick an option:"
options=(
    "Add an new port forwarding rule"
    "Remove an existing port forwarding rule"
    "List all port forwarding rules"
    "Save iptables rules"
    "Install iptables-persistent"
    "Enable IP forwarding"
)

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do 
    case "$REPLY" in
    1) manageForward -A;;
    2) manageForward -D;;
    3) listForward;;
    4) saveIptables;;
    5) installIptablesPersistent;;
    6) enableIpForwarding;;
    $((${#options[@]}+1))) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;
    esac
done
