use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;

my $debug = 0;
my ($env-var, $pdir);

# good tests
%*ENV<PB_LOTTERY_PRIVATE_DIR> = "t/data/good";
$env-var = "PB_LOTTERY_PRIVATE_DIR";
$pdir    = %*ENV{$env-var}; # hack

my $all   = 0;

# start with this ticket and modify it to get 0 to max winnings
my @tlines = [
    # $i == 0 match
    "11 12 13 14 15 11 2000-01-01 pp dp",

    # $i == 1 matches
    "01 12 13 14 15 11 2000-01-01 pp dp",

    # $i == 2 matches
    "01 02 13 14 15 11 2000-01-01 pp dp",

    # $i == 3 matches
    "01 02 03 14 15 11 2000-01-01 pp dp",

    # $i == 4 matches
    "01 02 03 04 15 11 2000-01-01 pp dp",

    # $i == 5 matches
    "01 02 03 04 05 11 2000-01-01 pp dp",

    # max
    # $i == 6 matches
    "01 02 03 04 05 01 2000-01-01 pp dp",
];

my @d = [
    "01 02 03 04 05 01 2000-01-01 pb 3x 100m",
    "01 02 03 04 05 01 2000-01-01 dp",
];

my $dobj = PB-Lottery::Draw.new: :numbers-str(@d.head), :numbers-str2(@d.tail);
isa-ok $dobj, PB-Lottery::Draw;

for @tlines.kv -> $i, $s is copy {
    $s = strip-comment $s;
    next unless $s ~~ /\S/;
    my $tobj = PB-Lottery::Ticket.new: :numbers-str($s);
    isa-ok $tobj, PB-Lottery::Ticket;
}

done-testing;

