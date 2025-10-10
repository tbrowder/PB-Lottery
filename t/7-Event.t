use Test;

use Text::Utils :strip-comment, :str2intlist;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;
use PB-Lottery::Event;

my $debug = 0;

my @dlines-raw = [
    '01 02 03 04 05 01 2000-01-01 3x $195m', # jackpot from 4 Oct 2025
    '01 02 03 04 05 01 2000-01-01 dp',
];

my @d;
for @dlines-raw -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    @d.push: $line;
}

my $draw = PB-Lottery::Draw.new: :numbers-str(@d.head), :numbers-str2(@d.tail);
isa-ok $draw, PB-Lottery::Draw, "new Draw";

my $ts = "11 12 13 14 15 11 2000-01-01 pp dp";
my $ticket = PB-Lottery::Ticket.new: :numbers-str($ts);
isa-ok $ticket, PB-Lottery::Ticket, "new Ticket";
my @tickets of PB-Lottery::Ticket;
@tickets.push: $ticket;

my $e = PB-Lottery::Event.new: :$draw, :@tickets;
isa-ok $e, PB-Lottery::Event, "new Event";
isa-ok $e.draw, PB-Lottery::Draw, "new Event's Draw";

for @tickets -> $t {
    isa-ok $t, PB-Lottery::Ticket, "isa Ticket";
}

# how to show event results:
# $e.tickets.head.print1;
# $e.tickets.head.print2;
# for the current verion, the following creates a good look:
# $e.draw.print1; print " | "; $e.draw.print2; say();

#$e.show;

done-testing;

=finish

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

my @draw = [
    '01 02 03 04 05 01 2000-01-01 3x $195m', # jackpot from 4 Oct 2025
    '01 02 03 04 05 01 2000-01-01 dp',
];

say @d.head;

my $draw = PB-Lottery::Draw.new: :numbers-str(@d.head), :numbers-str2(@d.tail);
isa-ok $draw, PB-Lottery::Draw;

my $d = Date.new: "2000-01-01";
is $draw.date, $d, "Date is $d as expected";

my @tickets;

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

   # make a full ticket for the Event test
   $ticket = PB-Lottery::Ticket.new: :numbers-str($s);
   @tickets.push: $ticket;
   # skip the rest for now
   next;
   
   for ($s1, $s2, $s3, $s4, $s5).kv -> $j, $S {
       $ticket = PB-Lottery::Ticket.new: :numbers-str($S);
       isa-ok $ticket, PB-Lottery::Ticket;

       $cash = calc-winnings :$ticket, :$draw;
       isa-ok $cash, Numeric;

       say "Total winnings: $cash":
   }
}

#my $e = PB-Lottery::Event.new: :$draw, :@tickets;
#isa-ok $e, PB-Lottery::Event;

done-testing;

