#!/usr/bin/env perl

use strict;
use MIME::Base64();

my $content;
while (<>) {
	$content .= $_;
}
$content =~ s/\s+//g;
print MIME::Base64::decode_base64($content);
