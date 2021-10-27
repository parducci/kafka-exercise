#!/bin/sh
# NAT
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o `ls /sys/class/net | grep e` -j MASQUERADE
