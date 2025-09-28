use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Classes;
use PB-Lottery::Indy;
use PB-Lottery::Subs;

is 1, 1, "sanity check";

# the draw object
my $s1 = "22 09 25 33 18 01 2025-09-22 3x";
my $s2 = "21 08 24 32 17 02 2025-09-22 dp";
my %h1 = create-numhash $s1;
isa-ok %h1, Hash, "good hash type";
my %h2 = create-numhash $s2;
isa-ok %h2, Hash, "good hash type";
my $od = PB-Draw.new: :numbers-str($s1), :numbers-str2($s2);
isa-ok $od, PB-Draw, "valid PB-Draw object";

# the ticket object
my $s3 = "21 06 24 32 17     02 2025-09-22 dp";
my %h3 = create-numhash $s3;
is %h3<a>, 6;
is %h3<b>, 17;
is %h3<c>, 21;
is %h3<d>, 24;
is %h3<e>, 32;
is %h3<f>, 2;

isa-ok %h3, Hash, "good hash type";
my $ot = PB-Ticket.new: :numbers-str($s3);
isa-ok $ot, PB-Ticket, "valid PB-Ticket object";

done-testing;
