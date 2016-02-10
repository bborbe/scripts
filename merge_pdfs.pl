#!/usr/bin/env perl

use strict;
use PDF::API2;

my @list = @ARGV;
my $new = PDF::API2->new;
foreach my $filename (@ARGV) {
  my $pdf = PDF::API2->open($filename);
  $new->importpage( $pdf, $_ ) foreach 1 .. $pdf->pages;
}
#warn $new->stringify();
$new->saveas('new.pdf');
