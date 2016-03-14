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
$IPTABLES -t nat -A POSTROUTING -o eth0 -s 10.4.0.0/8 -j MASQUERADE

#
# Transparent Proxy
#
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3128

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
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp --dport 1022 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp --dport 1022 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 1022 -j ACCEPT
# OpenVPN
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 563 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 563 -j ACCEPT
# Bind
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp -d 10.4.0.20 --dport 53 -j ACCEPT
# squid
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 3128 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp -d 10.20.0.1 --dport 3128 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 144.76.187.199 --dport 3128 -j ACCEPT

#
# Portforwarding
#
# Bind
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 53 -j DNAT --to-destination 10.4.0.20:53
$IPTABLES -t nat -A PREROUTING -i eth0 -p udp -d 144.76.187.199 --dport 53 -j DNAT --to-destination 10.4.0.20:53
# OpenVPN
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 563 -j DNAT --to-destination 10.4.0.20:563
# teamspeak 3
$IPTABLES -t nat -A PREROUTING -i eth0 -p udp -d 144.76.187.199 --dport 9987 -j DNAT --to-destination 10.4.0.23:9987
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 10011 -j DNAT --to-destination 10.4.0.23:10011
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 30033 -j DNAT --to-destination 10.4.0.23:30033
# minecraft
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 20000 -j DNAT --to-destination 10.4.0.1:20000
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 20001 -j DNAT --to-destination 10.4.0.1:20001
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 20002 -j DNAT --to-destination 10.4.0.1:20002
# mumble
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 64738 -j DNAT --to-destination 10.4.0.23:64738
$IPTABLES -t nat -A PREROUTING -i eth0 -p udp -d 144.76.187.199 --dport 64738 -j DNAT --to-destination 10.4.0.23:64738
# apache
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 80 -j DNAT --to-destination 10.4.0.1:80
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 144.76.187.199 --dport 443 -j DNAT --to-destination 10.4.0.1:443

#
# Forward
#
$IPTABLES -A FORWARD -i eth0 -o eth1 -j ACCEPT
$IPTABLES -A FORWARD -o eth0 -i eth1 -j ACCEPT
$IPTABLES -A FORWARD -i eth1 -o tap0 -j ACCEPT
$IPTABLES -A FORWARD -o eth1 -i tap0 -j ACCEPT
$IPTABLES -A FORWARD -i tap0 -o eth0 -j ACCEPT
$IPTABLES -A FORWARD -o tap0 -i eth0 -j ACCEPT

#
# Ports explizit sperren
#
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 111 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 111 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 111 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp --dport 139 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp --dport 139 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 139 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 6155 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 6155 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 6155 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 6780 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 6780 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 6780 -j DROP

#
# Rest loggen
#
$IPTABLES -A INPUT -j LOG --log-prefix="IPTABLES-INPUT: "
$IPTABLES -A OUTPUT -j LOG --log-prefix="IPTABLES-OUTPUT: "
$IPTABLES -A FORWARD -j LOG --log-prefix="IPTABLES-FORWARD: "
