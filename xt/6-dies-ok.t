# dies-ok single test only
my $n = 6;

use Test;

use lib "xt/lib";
use Helpers;

plan 1;

# This test calls a sub in module
# file '/xt/lib/Helpers.rakumod':

dies-ok {
    Leave;
}, "dies-ok test $n (Leave)";
