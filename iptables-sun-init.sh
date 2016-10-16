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
# Standardregel ACCEPT
#
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT

#
# Natd
#
$IPTABLES -t nat -A POSTROUTING -o br0 -s 172.16.0.0/12 -j MASQUERADE

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
# Forward
#
$IPTABLES -A FORWARD -j ACCEPT
$IPTABLES -A FORWARD -o br0 -i br0 -j ACCEPT
$IPTABLES -A FORWARD -i tap0 -o br0 -j ACCEPT
$IPTABLES -A FORWARD -o tap0 -i br0 -j ACCEPT
$IPTABLES -A FORWARD -i tap1 -o br0 -j ACCEPT
$IPTABLES -A FORWARD -o tap1 -i br0 -j ACCEPT
$IPTABLES -A FORWARD -i tun0 -o br0 -j ACCEPT
$IPTABLES -A FORWARD -o tun0 -i br0 -j ACCEPT
$IPTABLES -A FORWARD -i tun1 -o br0 -j ACCEPT
$IPTABLES -A FORWARD -o tun1 -i br0 -j ACCEPT

#
# Ports explizit sperren
#
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol tcp --dport 443 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 1947 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 8612 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 17500 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol tcp --dport 17500 -j DROP
$IPTABLES -A INPUT -j DROP -d 224.0.0.0/24 

#
# Rest loggen
#
$IPTABLES -A INPUT -j LOG --log-prefix="IPTABLES-INPUT: "
$IPTABLES -A OUTPUT -j LOG --log-prefix="IPTABLES-OUTPUT: "
$IPTABLES -A FORWARD -j LOG --log-prefix="IPTABLES-FORWARD: "

# Save rules
netfilter-persistent save
