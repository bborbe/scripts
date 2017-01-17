#!/usr/bin/env perl

use strict;
use Getopt::Long;
use Net::SMTP;

# config start
my $host = '127.0.0.1:25';
my $from = 'bborbe@rocketnews.de';
my $to = 'bborbe@rocketnews.de';
my $subject = 'subject';
my $helo = 'localhost.localdomain';

my $smtp = Net::SMTP->new(
  Host    => $host,
  Hello   => $helo,
  Timeout => 30,
  Debug   => 1,
);
$smtp->mail( $from );
$smtp->to( $to );
$smtp->data();
$smtp->datasend( 'To: '.$to."\r\n" );
$smtp->datasend( 'From: '.$from."\r\n" );
$smtp->datasend( 'Subject: '.$subject."\r\n" );
$smtp->datasend( "\r\n" );
while (<STDIN>) {
  $smtp->datasend( $_ );
}
$smtp->datasend( "\r\n" );
$smtp->dataend();
$smtp->quit;

exit(0);
