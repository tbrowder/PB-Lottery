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

my @tlines-raw = [
    "11 12 13 14 15 11 2000-01-01 pp dp",
    "01 12 13 14 15 11 2000-01-01 pp dp",
    "11 12 13 14 15 01 2000-01-01 pp dp",
];

my @tlines;
for @tlines-raw -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    @tlines.push: $line;
}

my @dlines;
for @dlines-raw -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/;
    @dlines.push: $line;
}

is @dlines.elems, 2, "have two lines per Draw object";
isa-ok @dlines.head, Str, "\@d.head isa Str";
isa-ok @dlines.tail, Str, "\@d.tail isa Str";

is @dlines.head.chars, 37, "dline1 has 37 chars: '{@dlines.head}'";
is @dlines.tail.chars, 31, "dline2 has 31 chars: '{@dlines.tail}'";

my $draw = PB-Lottery::Draw.new: :numbers-str(@dlines.head), 
           :numbers-str2(@dlines.tail);
isa-ok $draw, PB-Lottery::Draw, "new Draw";

my @t = [];
for @tlines -> $tline {
    my $t = PB-Lottery::Ticket.new: :numbers-str($tline);
    isa-ok $t, PB-Lottery::Ticket, "isa new Ticket";
    @t.push: $t;
}
for @t -> $t {
    isa-ok $t, PB-Lottery::Ticket, "isa Ticket";
}

my $e = PB-Lottery::Event.new: :$draw, :tickets(@t);
isa-ok $e, PB-Lottery::Event, "new Event";
isa-ok $e.draw, PB-Lottery::Draw, "new Event's Draw";

# how to show event results:
# $e.tickets.head.print1;
# $e.tickets.head.print2;
# for the current verion, the following creates a good look:
# $e.draw.print1; print " | "; $e.draw.print2; say();

$e.show-matches;

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

   =begin comment
   # skip the rest for now
   next;
   
   for ($s1, $s2, $s3, $s4, $s5).kv -> $j, $S {
       $ticket = PB-Lottery::Ticket.new: :numbers-str($S);
       isa-ok $ticket, PB-Lottery::Ticket;

       $cash = calc-winnings :$ticket, :$draw;
       isa-ok $cash, Numeric;

       say "Total winnings: $cash":
   }
   =end comment
}

#my $e = PB-Lottery::Event.new: :$draw, :@tickets;
#isa-ok $e, PB-Lottery::Event;

done-testing;

