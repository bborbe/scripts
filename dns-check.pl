#!/usr/bin/env perl

use strict;
use warnings;

my @dns_servers = qw/
  ns.rocketsource.de
  b.ns14.net
  c.ns14.net
  d.ns14.net
  8.8.8.8
  8.8.4.4
/;

sub get_ip {
  my ($host, $dns) = @_;
  my $result = `host $host $dns`;
  $result =~ /$host has address ([\d\.]+)/;
  return $1;
}

sub check_dns {
  my ($host, $dns_servers) = @_;
  my $results = {};
  foreach my $dns_server (@{$dns_servers}) {
    my $ip = get_ip($host, $dns_server);
    unless ($ip) {
      print STDERR "dns check failed! no ip found on dns server $dns_server.\n";
      exit(1);
    }
    push(@{$results->{$ip}},$dns_server);
  }
  if (keys(%$results) > 1) {
    print STDERR "dns check failed! different results: \n";
    while (my ($ip, $servers) = each %$results) {
      print STDERR $ip .' = ' .join(',', @$servers)."\n";
    }
    exit(1);
  }
  else {
    print "dns check success\n";
    exit(0);
  }
}

my $host = $ARGV[0];
unless ($host) {
  print STDERR "Usage: $0 [domain]\n";
  exit(1);
}
check_dns($host, \@dns_servers);
