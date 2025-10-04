use Test;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;

my $debug = 0;

my $t = "01 02 03 04 05 01 2000-01-01 pp dp";

my @d = [
    "01 02 03 04 05 01 2000-01-01 pb",
    "01 02 03 04 05 01 2000-01-01 dp",
];

my $tobj = PB-Lottery::Ticket.new: :numbers-str($t);
isa-ok $tobj, PB-Lottery::Ticket;

my ($line1, $line2) = "", "";
for @d -> $line is copy {
}

 
done-testing;

