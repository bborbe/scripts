#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

IPTABLES=/sbin/iptables

# IP-Forwarding im Kernel einschalten
/bin/echo 1 > /proc/sys/net/ipv4/ip_forward

#
# Firewallregeln loeschen
#
$IPTABLES -F
$IPTABLES -F -t nat
$IPTABLES -X
$IPTABLES -X -t nat

#
# Standardregel DROP
#
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP

#
# Natd
#
$IPTABLES -t nat -A POSTROUTING -o eth0 -s 10.0.0.0/8 -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -o eth0 -s 172.16.0.0/12 -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -o eth0 -s 192.168.0.0/16 -j MASQUERADE

#
# Allow localhost
#
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

#
# Ausgehende immer erlauben
#
$IPTABLES -A OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

#
# Antworten erlauben
#
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#
# Ports freigeben
#
# Ping
$IPTABLES -A INPUT -p icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type 11 -j ACCEPT
# SSH
$IPTABLES -A INPUT -m state --state NEW --protocol tcp --dport 22 -j ACCEPT

#
# Portforwarding
#
# OpenVpn
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 138.201.37.217 --dport 563 -j DNAT --to-destination 172.16.10.3:563
# Http + Https
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 138.201.37.217 --dport 80 -j DNAT --to-destination 172.16.10.2:1080
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 138.201.37.217 --dport 443 -j DNAT --to-destination 172.16.10.2:1443
# Minecraft
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 138.201.37.217 --dport 20001 -j DNAT --to-destination 172.16.10.2:20001
# Mumble
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 138.201.37.217 --dport 64738 -j DNAT --to-destination 172.16.10.2:64738
# Smtp + Imap
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 25 -j DNAT --to-destination 172.16.10.2:25
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 143 -j DNAT --to-destination 172.16.10.2:143
# Ts3
$IPTABLES -t nat -A PREROUTING -i eth0 -p udp -d 163.172.222.137 --dport 9987 -j DNAT --to-destination 172.16.10.10:30087
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 10011 -j DNAT --to-destination 172.16.10.2:10011
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 30033 -j DNAT --to-destination 172.16.10.2:30033
# Dns
$IPTABLES -t nat -A PREROUTING -i eth0 -p udp -d 163.172.222.137 --dport 53 -j DNAT --to-destination 172.16.10.10:30053
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 53 -j DNAT --to-destination 172.16.10.10:30054

#
# Forward
#
$IPTABLES -A FORWARD -j ACCEPT
$IPTABLES -A FORWARD -i eth0 -o privatebr0 -j ACCEPT
$IPTABLES -A FORWARD -i privatebr0 -o eth0 -j ACCEPT

#
# Ports explizit sperren
#
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 111 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp --dport 139 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 6155 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 6780 -j DROP
$IPTABLES -A INPUT -i privatebr0 -m state --state NEW --protocol tcp --dport 9100 -j DROP

#
# Rest loggen
#
$IPTABLES -A INPUT -j LOG --log-prefix="IPTABLES-INPUT: "
$IPTABLES -A OUTPUT -j LOG --log-prefix="IPTABLES-OUTPUT: "
$IPTABLES -A FORWARD -j LOG --log-prefix="IPTABLES-FORWARD: "

# Save rules
netfilter-persistent save
