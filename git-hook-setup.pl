#!/usr/bin/env perl

use strict;
use Fcntl;

unless (scalar(@ARGV) != 0) {
  print STDERR "Usage: $0 [BRANCH]\n";
  exit(1);
}

sysopen (FILE, '.git/hooks/pre-commit', O_RDWR|O_EXCL|O_CREAT, 0777);

print FILE '#!/bin/bash
BRANCH="$(git symbolic-ref HEAD 2>/dev/null)"
BRANCH=${BRANCH##refs/heads/}
echo "$BRANCH"
if [[ ';

my $first = 1;
for my $branch (@ARGV) {
    if ($first) {
        $first = 0;
    } else {
        print FILE ' || ';
    }
    print FILE '"$BRANCH" == "'.$branch.'"';
}


print FILE ' ]]; then
  echo "You are on branch $BRANCH. Are you sure you want to commit to this branch?"
  echo "If so, commit with -n to bypass this pre-commit hook."
  exit 1
fi
exit 0
';
