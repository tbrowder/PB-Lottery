# lives-ok single test only
my $n = 1;

use Test;

use lib "xt/lib";
use Helpers;

plan 1;

# This test calls a sub in module
# file '/xt/lib/Helpers.rakumod':

lives-ok {
    Okay;
}, "lives-ok test $n (Okay)";
