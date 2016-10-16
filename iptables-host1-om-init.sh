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
$IPTABLES -t nat -A POSTROUTING -o eth0 -s 172.16.0.0/12 -j MASQUERADE

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
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 80 -j DNAT --to-destination 172.16.60.2:1080
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 443 -j DNAT --to-destination 172.16.60.2:1443
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 163.172.222.137 --dport 563 -j DNAT --to-destination 172.16.60.3:563

#
# Forward
#
$IPTABLES -A FORWARD -j ACCEPT
$IPTABLES -A FORWARD -i eth0 -o pfsense-host -j ACCEPT
$IPTABLES -A FORWARD -i pfsense-host -o eth0 -j ACCEPT

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
