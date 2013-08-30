#!/bish/sh

# add in /etc/crontab
# 4 15 * * * root sh /root/scripts/backup_postgresql.sh >/dev/null 2>&1

LOCKFILE=/var/run/backup_postgresql.pid
BACKUP_NAME=/var/backups/postgres_`date '+%Y%m%d'`.sql.gz

#
# script below
#

echo "backup started"

if [ -e $BACKUP_NAME ]; then
	echo "backup already exists"
	exit
fi	

# lock script
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
  echo "already running"
  exit
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

su postgres -c pg_dumpall | gzip -9 > $BACKUP_NAME

# remove lock
echo "remove lock"
rm -f ${LOCKFILE}

echo "backup finished"  
