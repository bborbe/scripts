#!/usr/bin/env perl

use strict;
use warnings;

my $branch = `git rev-parse --abbrev-ref HEAD 2> /dev/null`;
$branch =~ s/^\s+|\s+$//g;
my $remote = `git remote get-url origin`;
print $remote;

# ssh://git@bitbucket.apps.seibert-media.net:7999/atl/confluence.git
# git@github.com:bborbe/scripts.git

$remote =~ /git@([^:]+):.*?([^\/]+)\/([^\/]+)\.git$/;
print "1=$1\n";
print "2=$2\n";
print "3=$3\n";
print "branch=$branch\n";
my $url;
if ($1 eq 'github.com') {
    $url = "https://github.com/$2/$3/compare/${branch}?expand=1";
} else {
    $url = "https://$1/projects/$2/repos/$3/compare/commits?sourceBranch=refs/heads/$branch";
}
exec ("open '$url'");
