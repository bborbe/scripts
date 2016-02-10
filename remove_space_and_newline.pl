#!/usr/bin/env perl

use strict;

while (<>) {
	my $content = $_;
	$content =~ s/\s+//g;
	print $content;
}
