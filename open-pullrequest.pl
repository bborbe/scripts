#!/usr/bin/env perl

use strict;
use warnings;

my $branch = `git rev-parse --abbrev-ref HEAD 2> /dev/null`;
$branch =~ s/^\s+|\s+$//g;
my $remote = `git remote get-url origin`;
$remote =~ /(git@|https:\/\/)([^:]+)[:\/].*?([^\/]+)\/([^\/]+?)(\.git)?$/;
my $url;
if ($2 eq 'github.com') {
    $url = "https://github.com/$3/$4/compare/${branch}?expand=1";
} else {
    $url = "https://$2/projects/$3/repos/$4/compare/commits?sourceBranch=refs/heads/$branch";
}
exec ("open '$url'");
