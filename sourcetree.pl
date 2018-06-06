#!/usr/bin/env perl

use strict;
use warnings;

use Cwd;
use File::Basename;

my $path;
if (@ARGV > 0) {
    $path = $ARGV[0];
} else {
    $path = Cwd::getcwd();
}
$path = Cwd::abs_path($path);

while ( ! -d $path.'/.git' ) {
    $path = dirname( $path ); 
    if ( $path eq '/' ) {
	print('cant find .git directory'."\n");
	exit(1);
    }
}

exec ('open -a SourceTree "'.$path.'"');

