use Test;

use PB-Lottery;
use PB-Lottery::Classes;
use PB-Lottery::Subs;

isa-ok PB-Lottery, PB-Lottery;

# miscellanous checks of subs and classes
my ($n1, $n2, $n3);
# good number strings:
$n1 = "32 01 64 02 42 01";
$n2 = "32 01 64 02 42 01 2025-09-06";
$n3 = "32 01 64 02 42 01 2025-09-06 dp";

for $n1, $n2, $n3 -> $n {
    lives-ok {
        my %h = Lstr2info-hash $n; 
    }, "good input: $n";
}

# bad number strings:
$n1 = "32 01 64 02 42 27";
$n2 = "32 01 70 02 42 01 2025-09-06";

for $n1, $n2 -> $n {
    dies-ok {
        my %h = Lstr2info-hash $n; 
    }, "bad input: $n";
}

done-testing;
