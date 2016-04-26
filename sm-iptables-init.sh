#!/bin/sh
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
$IPTABLES -t nat -A POSTROUTING -o eth0 -s 172.16.10.0/8 -j MASQUERADE

#
# Allow localhost
#
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

#
# Ausgehende immer erlauben
#
$IPTABLES -A OUTPUT -o eth0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o eth1 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o tap0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

#
# Antworten erlauben
#
$IPTABLES -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state ESTABLISHED,RELATED -j ACCEPT

#
# Ports freigeben
#
# Ping
$IPTABLES -A INPUT -i eth0 -p icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -p icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -p icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -p icmp --icmp-type 11 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -p icmp --icmp-type 11 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -p icmp --icmp-type 11 -j ACCEPT
# SSH
$IPTABLES -A INPUT -m state --state NEW --protocol tcp --dport 22 -j ACCEPT

#
# Portforwarding
#

#
# Forward
#

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

#
# Rest loggen
#
$IPTABLES -A INPUT -j LOG --log-prefix="IPTABLES-INPUT: "
$IPTABLES -A OUTPUT -j LOG --log-prefix="IPTABLES-OUTPUT: "
$IPTABLES -A FORWARD -j LOG --log-prefix="IPTABLES-FORWARD: "
