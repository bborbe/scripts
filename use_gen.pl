#!/usr/bin/env perl

use strict;
use Cwd;
use IO::File;

my $DEBUG = 0;
my $PACKAGE_NAME_REGEX = '([a-z][a-z0-9]*(::[a-z][a-z0-9_]*)+)';
my $file = $ARGV[0];
unless (-f $file) {
	print STDERR 'param file missing!';
	exit(1);
}

my @BLACKLIST = qw/
	SUPER
	UNIVERSAL
/;

my $fh = IO::File->new;
if ($fh->open('< '.Cwd::abs_path($file))) {
	warn 'open file success' if $DEBUG;
    my $content;
	while (<$fh>) {
		$content .= $_;
	}
	
	# comments entfernen
	$content =~ s/\n\s*#[^\n]*/\n/sgi;

	# package entfernen
	$content =~ s/package\s+$PACKAGE_NAME_REGEX;//sgi;

	# base entfernen
	$content =~ s/use\s+base[^\n]*//sgi;
	
	# use entfernen
	$content =~ s/use\s+$PACKAGE_NAME_REGEX;//sgi;
	
	my $packages = {};
    while ($content =~ /($PACKAGE_NAME_REGEX)/sgi) {
		$packages->{$1} = 1;
	}

	foreach my $black (@BLACKLIST) {
		foreach my $package (sort keys(%$packages)) {
			if ($package =~ /$black/) {
				delete($packages->{$package});
			}
		}
	}
	
	foreach my $package (sort keys(%$packages)) {
		print 'use '.$package.';'."\n";
	}

	$fh->close;
}

exit(0);
