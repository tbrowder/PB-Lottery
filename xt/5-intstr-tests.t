use Test;

use Text::Utils :strip-comment, :str2intlist;

use PB-Lottery::Subs;

my @lines = [
    "1 20 10",
];

for @lines.kv -> $i, $line {
    my @list = str2intlist $line;
    isa-ok @list, List;
    my $s = intlist2str @list;
    isa-ok $s, Str;
    is $s, "01 10 20", "str checks: |$s|";
}

done-testing;
