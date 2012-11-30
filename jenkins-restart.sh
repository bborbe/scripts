#!/bin/sh
if [ `ps ax | grep java | grep jenkins | grep -v grep | wc -l` == 0 ]
then
	echo "jenkins not running"
	/etc/init.d/jenkins restart
else
	echo "jenkins running"
fi
