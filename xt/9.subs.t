use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Ticket;
use PB-Lottery::Draw;
use PB-Lottery::Nums;
use PB-Lottery::Subs;

is 1, 1, "sanity check";

# the draw object
my $s1 = "22 09 25 33 18 01 2025-09-22 3x";
my $s2 = "21 08 24 32 17 02 2025-09-22 dp";
my %h1 = create-numhash $s1;
isa-ok %h1, Hash, "good hash type";
my %h2 = create-numhash $s2;
isa-ok %h2, Hash, "good hash type";

my $od = PB-Lottery::Draw.new: :numbers-str($s1), :numbers-str2($s2);
isa-ok $od, PB-Lottery::Draw, "valid Draw object";

# the ticket object
my $s3 = "21 06 24 32 17     02 2025-09-22 dp";
my %h3 = create-numhash $s3;
is %h3<a>, 6, "value is 6";
is %h3<b>, 17, "value is 17";
is %h3<c>, 21, "value is 21";
is %h3<d>, 24, "value is 24";
is %h3<e>, 32, "value is 32";
is %h3<f>, 2, "value is 2";

isa-ok %h3, Hash, "good hash type";
my $ot = PB-Lottery::Ticket.new: :numbers-str($s3);
isa-ok $ot, PB-Lottery::Ticket, "valid Ticket object";

done-testing;
