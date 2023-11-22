ceresIp=100.94.31.110

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

# add forwarding rules for ceres
addForward 80 $ceresIp 80
addForward 443 $ceresIp 443

# apply NAT
iptables -t nat -A POSTROUTING -j MASQUERADE

# enable ip forwarding
sysctl -w net.ipv4.ip_forward=1

saveNewIptables
