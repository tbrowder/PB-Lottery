use Test;

use PB-Lottery;
use PB-Lottery::Indy;

my ($env-var, $pdir);

# good tests
%*ENV<PB_LOTTERY_PRIVATE_DIR> = "t/data/good";
$env-var = "PB_LOTTERY_PRIVATE_DIR";
$pdir    = %*ENV{$env-var}; # hack

my $all   = 0;
my $debug = 0;

lives-ok {
    do-status $pdir;
    :$all,
    :$debug,
}, "do-status";

lives-ok {
    do-pick $pdir;
    :$debug,
}, "do-pick";

=begin comment
lives-ok {
    do-enter-pick $pdir;
    :$debug,
}, "do-enter-pick";

lives-ok {
    do-enter-draw $pdir;
    :$debug,
}, "do-enter-draw";
=end comment

done-testing;
