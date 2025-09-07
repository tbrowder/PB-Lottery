# lives-ok single test only
my $n = 2;

use Test;

use lib "xt/lib";
use Helpers;

plan 1;

# This test calls a sub in module
# file '/xt/lib/Helpers.rakumod':

lives-ok {
    Exit;
}, "lives-ok test $n (Exit)";
