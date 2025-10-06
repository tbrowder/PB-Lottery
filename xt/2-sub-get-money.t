use Test;

use PB-Lottery::Subs;
use PB-Lottery::Vars;

my $res = 1_400_000_000;

# $1.4b
my $m1 = <$1.4b>;
my $n1 = get-dollars $m1;
is $n1, $res;

# 1,400m
my $m2 = "1,400m";
$m2 = get-dollars $m2;
is $m2, $res;

# 1,400,000t
my $m3 = "1,400,000t";
$m3 = get-dollars $m3;
is $m3, $res;

# 1,400,000,000.00
my $m4 = "1,400,000,000.00";
$m4 = get-dollars $m4;
is $m4, $res;

done-testing;
