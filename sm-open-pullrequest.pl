#!/usr/bin/env perl

use strict;
use warnings;

my $branch = `git rev-parse --abbrev-ref HEAD 2> /dev/null`;
my $remote = `git remote get-url origin`;
$remote =~ /([^\/]+)\/([^\/]+)\.git$/;
my $url = "https://bitbucket.apps.seibert-media.net/projects/$1/repos/$2/compare/commits?sourceBranch=refs/heads/$branch";
exec ("open $url");


