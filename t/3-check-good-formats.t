use Test;
use Test::Output;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;
use PB-Lottery::Event;
use PB-Lottery::Win;

my ($env-var, $pdir);

# good tests
%*ENV<PB_LOTTERY_PRIVATE_DIR> = "t/data/good";
$env-var = "PB_LOTTERY_PRIVATE_DIR";
$pdir    = %*ENV{$env-var}; # hack

my $all   = 0;
my $debug = 0;
# read the status of the "good" draws and tickets

lives-ok {
    #stdout-from { do-status $pdir };
    my $x = stdout-from { do-status $pdir };
}, "good read of existing data";

=begin comment
lives-ok {
    # another way, from Lizmat: 2025-10-31
    # DOES NOT WORK WIT MI6
    $*OUT = open "/dev/null", :w;
    do-status $pdir;
}, "good read of existing data";
=end comment

done-testing;
