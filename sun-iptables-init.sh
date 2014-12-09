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
# Standardregel 
#
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT

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
$IPTABLES -A FORWARD -i tap0 -o br0 -j ACCEPT
$IPTABLES -A FORWARD -o tap0 -i br0 -j ACCEPT
$IPTABLES -A FORWARD -i tap1 -o br0 -j ACCEPT
$IPTABLES -A FORWARD -o tap1 -i br0 -j ACCEPT
$IPTABLES -A FORWARD -o br0 -i br0 -j ACCEPT

#
# Ports explizit sperren
#
$IPTABLES -A INPUT -m state --state NEW --protocol udp --dport 17500 -j DROP
$IPTABLES -A INPUT -m state --state NEW --protocol tcp --dport 17500 -j DROP
$IPTABLES -A INPUT -j DROP -d 224.0.0.0/24 
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 67 -j DROP

#
# Rest loggen
#
$IPTABLES -A INPUT -j LOG --log-prefix="IPTABLES-INPUT: "
$IPTABLES -A OUTPUT -j LOG --log-prefix="IPTABLES-OUTPUT: "
$IPTABLES -A FORWARD -j LOG --log-prefix="IPTABLES-FORWARD: "
