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

title="Hello! This is a script manage port forwarding using iptables"
title=""
prompt="Pick an option:"
options=(
    "Add an new port forwarding rule"
    "Remove an existing port forwarding rule"
    "List all port forwarding rules"
    "Save iptables rules"
    "Install iptables-persistent"
)

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do 
    case "$REPLY" in
    1) manageForward -A;;
    2) manageForward -D;;
    3) listForward;;
    4) saveIptables;;
    6) installIptablesPersistent;;
    $((${#options[@]}+1))) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;
    esac
done
