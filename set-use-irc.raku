#!/usr/bin/env raku

use Test;

my $s = "10 1";

sub F(
    Str $s
    --> List
) is export {
    my @ints = $s.words.map({ .Int });
    @ints.unique.sort({ $^a <=> $^b });
}

my @ints = F($s);
.say for @ints;
ok @ints, List;
