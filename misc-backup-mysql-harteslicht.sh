#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# add in /etc/crontab
# 4 15 * * * root sh /root/scripts/misc-backup-mysql-harteslicht.sh >/dev/null 2>&1
#
# add mysql backup user
# GRANT SELECT ON harteslicht.* TO backup IDENTIFIED BY "AMwuzKJvh3ubCjrU";
# GRANT SELECT ON harteslicht.* TO backup@localhost IDENTIFIED BY "AMwuzKJvh3ubCjrU";

DATABASE=harteslicht
DATABASE_USERNAME=backup
DATABASE_PASSWORD=AMwuzKJvh3ubCjrU
LOCKFILE=/var/run/backup_mysql_${DATABASE}.pid
BACKUP_NAME=/var/backups/mysql_${DATABASE}_`date '+%Y%m%d'`.sql.gz

#
# script below
#

echo "backup ${DATABASE} started"

if [ -e $BACKUP_NAME ]; then
	echo "backup ${DATABASE} already exists"
	exit
fi	

# lock script
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
  echo "backup ${DATABASE} already running"
  exit
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

mysqldump --lock-tables=false -u ${DATABASE_USERNAME} --password=${DATABASE_PASSWORD} ${DATABASE} | gzip -9 > $BACKUP_NAME

# remove lock
echo "backup ${DATABASE} remove lock"
rm -f ${LOCKFILE}

echo "backup ${DATABASE} finished"  
