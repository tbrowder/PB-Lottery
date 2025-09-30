use Test;

my $set5nums = set(1..69);
my $setpb    = set(1..26);

is 1,1, "sanity check";
# with a set of 5 numbers, ensure:
#   + all numbers are unique
#   + all are in $set5nums


# with a set of 1 number, ensure:
#   + it is an element of $setpb

done-testing;

