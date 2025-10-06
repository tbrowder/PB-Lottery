use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;

my $debug = 0;

my $all   = 0;

# start with this ticket and modify it to get 0 to max winnings
# use jackpot value from 4 Oct 2025: $195m
my @tlines-raw = [
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

my @tlines = [];
# strip comments from the strings above

for @tlines-raw -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    @tlines.push: $line;
}

my @d = [
    "01 02 03 04 05 01 2000-01-01 pb 3x $195m", # jackpot from 4 Oct 2025
    "01 02 03 04 05 01 2000-01-01 dp",
];

my $draw = PB-Lottery::Draw.new: :numbers-str(@d.head), :numbers-str2(@d.tail);
isa-ok $draw, PB-Lottery::Draw;

for @tlines.kv -> $i, $s {
   
   my $ticket = PB-Lottery::Ticket.new: :numbers-str($s);
   isa-ok $ticket, PB-Lottery::Ticket;

   my $cash = calc-winnings :$ticket, :$draw;
   if $cash.defined {
       isa-ok $cash, Numeric;
       #isa-ok $cash, Any;
   }
}

# the actual prizes possible for the various options
my @powerball = [
"5+pb jackpot",
"5    1_000_000",
"4+pb 50_000",
"4    100",
"3+pb 100",
"3    7",
"2+pb 7",
"1+pb 4",
"pb   4",
];

my @power-play = [
"5+pb n/a",
"5    2_000_000",
"4+pb 100_000",
"4    200",
"3+pb 200",
"3    14",
"2+pb 14",
"1+pb 8",
"pb   8",
];

my @double-play = [
"5+pb 10_000_000",
"5    500_000",
"4+pb 50_000",
"4    500",
"3+pb 500",
"3    20",
"2+pb 20",
"1+pb 10",
"pb   7",
];

done-testing;

