#!/usr/bin/env perl

use strict;

my $filename = 'go.mod';

open(FH, '<', $filename) or die $!;
my $content = '';
while(<FH>){
   $content .= $_;
}
close(FH);

$content =~ s/require\s+[^\(].*$//;
$content =~ s/require\s+\(.*\)//s;
$content =~ s/\n+/\n/g;

open(FH, '>', $filename) or die $!;
print FH $content;
close(FH);
