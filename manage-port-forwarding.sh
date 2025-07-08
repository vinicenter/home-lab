#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

saveIptables() {
    netfilter-persistent save
}

installIptablesPersistent() {
    apt install -y iptables-persistent
}

manageForward() {
    local operation=$1

    read -p "Enter protocol (tcp/udp): " protocol
    read -p "Enter local port: " localPort
    read -p "Destination IP: " ip
    read -p "Destination port: " remotePort

    if [ "$operation" = "-A" ]; then
        # Redirects only if origin is not Tailscale (100.64.0.0/10)
        iptables -t nat -A PREROUTING ! -s 100.64.0.0/10 -p "$protocol" --dport "$localPort" -j DNAT --to-destination "$ip:$remotePort"
        iptables -t nat -A POSTROUTING -j MASQUERADE
    else
        # Remove rule
        iptables -t nat -D PREROUTING -p "$protocol" --dport "$localPort" -j DNAT --to-destination "$ip:$remotePort"
    fi
}

listForward() {
    iptables -t nat -L PREROUTING -n -v
}

enableIpForwarding() {
    isIpForwardingEnabled=$(cat /proc/sys/net/ipv4/ip_forward)

    if [ isIpForwardingEnabled -eq 1 ]; then
        echo "IP forwarding is already enabled"
    else
        echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
        sysctl -p
        echo "IP forwarding enabled"
    fi
}

title="Port Forwarding Manager (iptables)"
prompt="Choose an option:"
options=(
    "Add redirect rule"
    "Remove redirect rule"
    "List redirect rules"
    "Save iptables rules"
    "Install iptables-persistent"
    "Enable IP Forwarding"
)

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Sair"; do 
    case "$REPLY" in
        1) manageForward -A ;;
        2) manageForward -D ;;
        3) listForward ;;
        4) saveIptables ;;
        5) installIptablesPersistent ;;
        6) enableIpForwarding ;;
        $((${#options[@]}+1))) echo "Saindo..."; break ;;
        *) echo "Opção inválida. Tente novamente." ;;
    esac
done
