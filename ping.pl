#!/usr/bin/env perl

use strict;
use DateTime;
use LWP::Simple;	

my $dt = DateTime->now;
$dt->set_time_zone( 'Europe/Berlin' );

print $dt->datetime.' '.name()."\n";

sub name {	
	my $content = get('https://www.benjamin-borbe.de/ip/');
	if ($content eq '217.19.181.138') {
		return 'seibert-media';
	} else {
		return 'other';
	}
}
