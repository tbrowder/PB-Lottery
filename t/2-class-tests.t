use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Nums;

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

my @dlines = "$pdir/draws.txt".IO.lines;
for @dlines -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    $line = $line.words[0..^6].join;
    my $o = PB-Lottery::Nums.new: :num-str($line);
    isa-ok $o, PB-Lottery::Nums;
}

my @tlines = "$pdir/my-tickets.txt".IO.lines;
for @tlines -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    $line = $line.words[0..^6].join;
    my $o = PB-Lottery::Nums.new: :num-str($line);
    isa-ok $o, PB-Lottery::Nums;
}

done-testing;

