use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;

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

done-testing;

