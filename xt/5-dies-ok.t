# dies-ok single test only
my $n = 5;

use Test;

use lib "xt/lib";
use Helpers;

plan 1;

# This test calls a sub in module
# file '/xt/lib/Helpers.rakumod':

dies-ok {
    Exit;
}, "dies-ok test $n (Exit)";
