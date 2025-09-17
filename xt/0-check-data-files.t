use Test;

use PB-Lottery;

my $env-var = "PB_LOTTERY_PRIVATE_DIR";
my $pdir = %*ENV{$env-var}.IO.d; # hack
say $pdir;

is 1, 1;

#done-testing;
#=finish
lives-ok {
    run "do-status", $pdir;
}, "do-status";

done-testing;
