use Test;

use Text::Utils;

use PB-Lottery;
use PB-Lottery::Classes;
use PB-Lottery::Indy;

# valid ticket strings
my @t = [
"09 12 22 41 61 25 2025-08-27 pb",
"02 17 22 27 33 17 2025-08-30 pb dp",
"03 16 29 61 69 22 2025-09-03 dp",
"09 12 22 41 61 25 2025-08-27 pb qp",
"02 17 22 27 33 17 2025-08-30 pb dp qp",
"03 16 29 61 69 22 2025-09-03 pp",
];

for @t -> $t {
    my $to = PB-Ticket.new: :numbers-str($t);
    isa-ok $to, PB-Ticket;
}

