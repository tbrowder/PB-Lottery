use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;
use PB-Lottery::Event;

my ($env-var, $pdir);

# good tests
%*ENV<PB_LOTTERY_PRIVATE_DIR> = "t/data/good";
$env-var = "PB_LOTTERY_PRIVATE_DIR";
$pdir    = %*ENV{$env-var}; # hack

my $all   = 0;
my $debug = 0;

my @dlines = "$pdir/draws.txt".IO.lines;
for @dlines -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    my $o = PB-Lottery::Numbers.new: :numbers-str($line);
    isa-ok $o, PB-Lottery::Numbers;
}

my @tlines = "$pdir/my-tickets.txt".IO.lines;
for @tlines -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    my $o = PB-Lottery::Numbers.new: :numbers-str($line);
    isa-ok $o, PB-Lottery::Numbers;
}

done-testing;
