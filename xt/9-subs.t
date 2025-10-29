use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Ticket;
use PB-Lottery::Draw;
use PB-Lottery::Numbers;
use PB-Lottery::Subs;
use PB-Lottery::Vars;
use PB-Lottery::Event;

is 1, 1, "sanity check";

# the draw object
my $s1 = "22 09 25 33 18 01 2025-09-22 3x";
my $s2 = "21 08 24 32 17 02 2025-09-22 dp";

my $draw = PB-Lottery::Draw.new: :numbers-str($s1), :numbers-str2($s2);
isa-ok $draw, PB-Lottery::Draw, "valid Draw object";

# the ticket object
my $s3 = "21 06 24 32 17     02 2025-09-22 dp";

my $ticket = PB-Lottery::Ticket.new: :numbers-str($s3);
isa-ok $ticket, PB-Lottery::Ticket, "valid Ticket object";

done-testing;
