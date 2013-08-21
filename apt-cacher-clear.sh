#!/bin/sh

/etc/init.d/apt-cacher stop
mv /var/cache/apt-cacher /var/cache/apt-cacher.old
rm -rf /var/cache/apt-cacher.old &
mkdir -p /var/cache/apt-cacher/{headers,import,packages,private,temp}
chown -R www-data:www-data /var/cache/apt-cacher
/etc/init.d/apt-cacher start
