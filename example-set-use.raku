#!/usr/bin/env raku

use Test;

my ($a, $b) = set(1..3), set(2, 4);

my $res;

my $c = set(1..4);
my $d = set(3..6);
my $e = set(1..6);

is ($a (<) $c), True, "proper subset";
is ($c (<) $c), False, "not proper subset";
is ($c (<=) $c), True, "in set";
is ($c !(<=) $c), False, "in set";

# other set operations
my $j = $a (&) $b; # intersection
# set difference
# union


