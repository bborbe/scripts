#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "start cleanup"
sudo killall -9 java
sudo killall -9 perl

echo "clean core dumps started"
sudo sysctl -w kern.coredump=0
sudo rm -f /cores/*

echo "clean mails"
sudo killall Mail
sudo rm -rf /opt/local/var/log/mysql5/*
#sudo rm -rf /Users/bborbe/Library/Mail/IMAP-*
#sudo rm -rf /Users/bborbe/Library/Mail/POP-*
#sudo rm -rf /Users/bborbe/Library/Mail/V2/IMAP-*
#sudo rm -rf /Users/bborbe/Library/Mail/V2/POP-*

echo "clean workspace"
find ~/Documents/workspaces -name "target" -exec rm -rf "{}" \;
find ~/Documents/workspaces/go/src/github.com/bborbe -name "node_modules" -exec rm -rf "{}" \;
find ~/Documents/workspaces/go/src/github.com/bborbe -name "vendor" -exec rm -rf "{}" \;
find ~/Documents/workspaces -name "org.maven.ide.eclipse" -exec rm -rf "{}" \;
sudo rm -rf /Users/bborbe/.cpan/build

echo "clean logs"
sudo rm -rf /opt/apache-tomcat-7.0.56/logs/*
sudo rm -rf /opt/apache-tomcat-8.0.20/logs/*
sudo rm -f /var/log/*.bz2
sudo rm -f /var/log/asl/*
sudo find ~/Library/Logs -type f ! -name ping.log -exec rm -f "{}" \;
sudo find /Library/Logs -type f -exec rm -f "{}" \;

echo "clean proxy"
sudo rm -rf /opt/local/var/squid/logs/*
sh ~/bin/proxy.sh restart

#echo "clean ports"
#sudo port clean all

echo "remove sleep image"
sudo rm /private/var/vm/sleepimage
sudo pmset -a hibernatemode 0

echo "clean manually ~/Library/Caches"
echo "clean manually /Library/Caches"
