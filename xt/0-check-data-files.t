use Test;

use PB-Lottery;

my $env-var = "PB_LOTTERY_PRIVATE_DIR";
my $pdir = %*ENV{$env-var}; # hack

lives-ok {
    do-status $pdir;
}, "do-status";

done-testing;
