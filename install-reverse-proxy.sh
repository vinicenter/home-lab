#!/bin/bash

installIptablesPersistent() {
    apt install iptables-persistent
}

addForward() {
    local localPort=$1
    local ip=$2
    local remotePort=$3

    iptables -t nat -A PREROUTING -p tcp --dport $localPort -j DNAT --to-destination $ip:$remotePort
}

saveNewIptables() {
    su -c 'iptables-save > /etc/iptables/rules.v4'
    su -c 'ip6tables-save > /etc/iptables/rules.v6'
}

# install iptables-persistent
installIptablesPersistent

echo "Enter target IP: "
read targetIp

# add forwarding rules for targetIp
addForward 80 $targetIp 80
addForward 443 $targetIp 443

# apply NAT
iptables -t nat -A POSTROUTING -j MASQUERADE

# enable ip forwarding
sysctl -w net.ipv4.ip_forward=1

saveNewIptables
