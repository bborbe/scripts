#!/usr/bin/env perl

use strict;
use DateTime;
use LWP::Simple;	

my $dt = DateTime->now;
$dt->set_time_zone( 'Europe/Berlin' );

print $dt->datetime.' '.name()."\n";

sub name {
  my $content = get('https://ip.benjamin-borbe.de');
  if ($content eq '217.19.181.138' or $content eq '188.172.114.68') {
    return 'seibert-media';
  } else {
    return 'other';
  }
}

