use Test;

my $s = "2025-09-26";
my $d = Date.new: $s;
isa-ok $d, Date;

done-testing;

