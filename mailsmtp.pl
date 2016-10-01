#!/usr/bin/env perl

use strict;
use Getopt::Long;
use Net::SMTP;

# config start
my $host = '127.0.0.1:1025';
#my $host = 'www.benjamin-borbe.de:25';
my $from = 'form';
my $to = 'test';
my $subject = 'subject';

my $smtp = Net::SMTP->new( $host );
$smtp->mail( $from );
$smtp->to( $to );
$smtp->data();
$smtp->datasend( 'Subject: '.$subject."\r\n" );
$smtp->datasend( 'To: '.$to."\r\n" );
$smtp->datasend( "\r\n" );
while (<STDIN>) {
  $smtp->datasend( $_ );
}
$smtp->datasend( "\r\n" );
$smtp->dataend();
$smtp->quit;

exit(0);
