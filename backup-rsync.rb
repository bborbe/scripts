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
    'client_host'  => 'burn.hm.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'fire.hm.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'proxy.hm.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'freenas.hm.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'sun.pn.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'backup.pn.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'true',
    'client_user'  => 'root',
    'client_host'  => 'fw.rn.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'a.rn.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'b.rn.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'cfn.rn.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'misc.rn.benjamin-borbe.de',
    'client_dir'   => '/', 
    'exclude_from' => '/root/scripts/backup-rsync-exclude-from',
  },
  {
    'active'       => 'false',
    'client_user'  => 'root',
    'client_host'  => 'confluence.rn.benjamin-borbe.de',
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
    if system('mount /rsync')
      puts 'mount /rsync completed'
    else 
      puts 'mount /rsync failed'
      return
    end
  else
    puts 'already mounted /rsync'
  end

  # create current link if not already exists
  if File.symlink? $BACKUP_DIR + '/' + client_host + '/current'
    puts 'current link already exists'
  else
    puts 'current link exists not'
    if system('mkdir -p ' + $BACKUP_DIR + '/' + client_host + '/empty')
      puts 'mkdir empty directory'
    else
      puts 'mkdir empty directory failed'
      return
    end    
#    if system('ln -s ' + $BACKUP_DIR + '/' + client_host + '/empty ' + $BACKUP_DIR + '/' + client_host + '/current')
    if system('ln -s empty ' + $BACKUP_DIR + '/' + client_host + '/current')
      puts 'link empty to current'
    else
      puts 'link empty to current failed'
      return
    end
  end

  puts 'delete incomplete backups'
  if system('rm -rf ' + $BACKUP_DIR + '/' + client_host + '/incomplete-*')
    puts 'delete old incomplete backups'
  else 
    puts 'delete old incomplete backups failed'
    return
  end

  puts 'mkdir target incomplete directory'
  if system('mkdir -p ' + $BACKUP_DIR + '/' + client_host + '/incomplete-' + $DATE + client_dir)
    puts 'mkdir target incomplete directory success'
  else
    puts 'mkdir target incomplete directory failed'
    return
  end

  puts 'rsync'
  if system('rsync -azP --delete --delete-excluded --exclude-from=' + exclude_from + ' --link-dest=' + $RSYNC_LINK + ' ' + $RSYNC_FROM + ' ' + $RSYNC_TO)
    puts 'rsync success'
  else 
    puts 'rsync failed'
    return
  end

  puts 'move incomplete from directory name'
  if system('mv ' + $BACKUP_DIR + '/' + client_host + '/incomplete-' + $DATE + ' ' + $BACKUP_DIR + '/' + client_host + '/' + $DATE)
    puts 'move incomplete from directory name success'
  else
    puts 'move incomplete from directory name failed'
    return
  end
 
  puts 'update current link'
  if system('rm -f ' + $BACKUP_DIR + '/' + client_host + '/current')
    puts 'remove old current link success'
  else 
    puts 'remove old current link failed'
    return
  end
#  if system('ln -s ' + $BACKUP_DIR + '/' + client_host + '/' + $DATE + ' ' + $BACKUP_DIR + '/' + client_host + '/current')
  if system('ln -s ' + $DATE + ' ' + $BACKUP_DIR + '/' + client_host + '/current')
    puts 'create new current link success'
  else 
    puts 'create new current link failed'
    return
  end

  puts 'delete empty'
  if system('rm -rf ' + $BACKUP_DIR + '/' + client_host + '/empty')
    puts 'delete empty directory success'
  else 
    puts 'delete empty directory failed'
    return
  end

  # # remove lock
  puts 'remove lock'
  File.delete($LOCKFILE) if File.file?( $LOCKFILE ) 

  puts 'backup-rsync finished'

end

# iterate of all configs
configs.each { |config| 
  if config['active'] == 'true' 
    puts 'client_user:  ' + config['client_user']
    puts 'client_host:  ' + config['client_host']
    puts 'client_dir:   ' + config['client_dir']
    puts 'exclude_from: ' + config['exclude_from']
    puts 'active:       ' + config['active']
    backup(config['client_user'], config['client_host'], config['client_dir'], config['exclude_from'])
  else 
    puts 'skip backup of ' + config['client_host']
  end
}

