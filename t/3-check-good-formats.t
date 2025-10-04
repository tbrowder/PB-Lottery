use Test;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;

my ($env-var, $pdir);

# good tests
%*ENV<PB_LOTTERY_PRIVATE_DIR> = "t/data/good";
$env-var = "PB_LOTTERY_PRIVATE_DIR";
$pdir    = %*ENV{$env-var}; # hack

my $all   = 0;
my $debug = 0;

# read the status of the "good" draws and tickets
lives-ok {
    do-status $pdir;
}, "good read of existing data";

done-testing;

