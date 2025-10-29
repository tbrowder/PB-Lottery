use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;
#use PB-Lottery::Event;

my $debug = 0;

# start with this ticket and modify it to get 0 to max winnings
# use jackpot value from 4 Oct 2025: $195m
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
    '01 02 03 04 05 01 2000-01-01 3x $195m', # jackpot from 4 Oct 2025
    '01 02 03 04 05 01 2000-01-01 dp',
];

my $draw = PB-Lottery::Draw.new: :numbers-str(@d.head), :numbers-str2(@d.tail);
isa-ok $draw, PB-Lottery::Draw;

my $d = Date.new: "2000-01-01";
is $draw.date, $d, "Date is $d as expected";

# the index number of the Ticket lines can be
# used to check the expected winnings
for @tlines.kv -> $i, $s {

   my $s0 = $s.words[0..^7].join(' ');
   # make four tickets out of the common string
   my $s1 = $s0 ~ " pb"; # plain powerball
   my $s2 = $s0 ~ " pp"; # add power play
   my $s3 = $s0 ~ " dp"; # add double play
   my $s4 = $s;          # pb + pp + dp
   my $s5 = $s0 ~ " paid"; # ignore it

   my ($ticket, $cash, $exp-prize);
#  for ($s1, $s2, $s3, $s4).kv -> $j, $S {
   for ($s1, $s2, $s3, $s4, $s5).kv -> $j, $S {
       $ticket = PB-Lottery::Ticket.new: :numbers-str($S);
       isa-ok $ticket, PB-Lottery::Ticket;

       $cash = calc-winnings :$ticket, :$draw;
       isa-ok $cash, Win;

       say "Total winnings: $cash":
   }
}

done-testing;
