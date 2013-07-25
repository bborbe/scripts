#!/usr/bin/env ruby
 
require 'open3'

#
# Config
#


# Slash at the end of client_dir is important!
configs = [
  {
    'active'       => 'true',
    'client_user'  => 'root',
    'client_host'  => 'fire',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => '192.168.178.49',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
]

def backup (client_user, client_host, client_dir, exclude_from)
  $DEBUG = true
  $DATE = `date "+%Y-%m-%dT%H:%M:%S"`.chomp
  $BACKUP_DIR = '/rsync'
  $RSYNC_FROM = client_user + '@' + client_host + ':' + client_dir
  $RSYNC_TO = $BACKUP_DIR + '/' + client_host + '/incomplete-' + $DATE + client_dir
  $RSYNC_LINK = $BACKUP_DIR + '/' + client_host + '/current' + client_dir
  $LOCKFILE = '/var/run/backup-rsync.pid'

  if $DEBUG
    puts 'DATE         = "' + $DATE + '"'
    puts 'CLIENT_USER  = "' + client_user + '"'
    puts 'CLIENT_HOST  = "' + client_host + '"'
    puts 'CLIENT_DIR   = "' + client_dir + '"'
    puts 'BACKUP_DIR   = "' + $BACKUP_DIR + '"'
    puts 'EXCLUDE_FROM = "' + exclude_from + '"'
    puts 'RSYNC_FROM   = "' + $RSYNC_FROM + '"'
    puts 'RSYNC_TO     = "' + $RSYNC_TO + '"'
    puts 'RSYNC_LINK   = "' + $RSYNC_LINK + '"'
    puts 'LOCKFILE     = "' + $LOCKFILE + '"'
  end

  #
  # Script
  #

  puts 'backup-rsync started'

  # lock script
  if File.file?( $LOCKFILE ) 
    puts 'lock exists'
    file = File.open($LOCKFILE, "rb")
    contents = file.read
    if system('kill -0 '+contents)
      puts 'already runnung'
      exit
    else 
      puts 'not running'
    end 
  else
    puts 'lock exists not'
  end

  # insert pid in lockfile
  pid = Process.pid
  puts 'pid = ' + pid.to_s
  newFile = File.open($LOCKFILE, "w")
  newFile.write(pid)
  newFile.close

  # mount /rsync if needed
  stdin, stdout, stderr = Open3.popen3('mount |grep /rsync | wc -l')
  mounts = stdout.readline.chomp
  if mounts == '0'
    puts 'mount /rsync'
    system('mount /rsync')
  else
    puts 'already mounted /rsync'
  end

  # create current link if not already exists
  if File.symlink? $BACKUP_DIR + '/' + client_host + '/current'
    puts 'current link already exists'
  else
    puts 'current link exists not'
    system('mkdir -p ' + $BACKUP_DIR + '/' + client_host + '/empty')
    system('ln -s ' + $BACKUP_DIR + '/' + client_host + '/empty ' + $BACKUP_DIR + '/' + client_host + '/current')
  end

  puts 'delete incomplete backups'
  system('rm -rf ' + $BACKUP_DIR + '/' + client_host + '/incomplete-*')

  puts 'mkdir target incomplete directory'
  system('mkdir -p ' + $BACKUP_DIR + '/' + client_host + '/incomplete-' + $DATE + client_dir)

  puts 'rsync'
  system('rsync -azP --delete --delete-excluded --exclude-from=' + exclude_from + ' --link-dest=' + $RSYNC_LINK + ' ' + $RSYNC_FROM + ' ' + $RSYNC_TO)

  puts 'move incomplete from directory name'
  system('mv ' + $BACKUP_DIR + '/' + client_host + '/incomplete-' + $DATE + ' ' + $BACKUP_DIR + '/' + client_host + '/' + $DATE)

  puts 'update current link'
  system('rm -f ' + $BACKUP_DIR + '/' + client_host + '/current')
  system('ln -s ' + $BACKUP_DIR + '/' + client_host + '/' + $DATE + ' ' + $BACKUP_DIR + '/' + client_host + '/current')

  puts 'delete empty'
  system('rm -rf ' + $BACKUP_DIR + '/' + client_host + '/empty')

  # # remove lock
  puts 'remove lock'
  File.delete($LOCKFILE) if File.file?( $LOCKFILE ) 

  puts 'backup-rsync finished'

end

# iterate of all configs
configs.each { |config| 
  puts 'client_user:  ' + config['client_user']
  puts 'client_host:  ' + config['client_host']
  puts 'client_dir:   ' + config['client_dir']
  puts 'exclude_from: ' + config['exclude_from']
  puts 'active:       ' + config['active']
  if config['active'] == 'true' 
    backup(config['client_user'], config['client_host'], config['client_dir'], config['exclude_from'])
  else 
    puts 'skip backup of ' + config['client_host']
  end
}

