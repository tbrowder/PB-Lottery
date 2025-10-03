use Test;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Nums;

isa-ok PB-Lottery, PB-Lottery;

# miscellanous checks of subs and classes
my ($n1, $n2, $n3);
my ($e1, $e2, $e3);
my (%h);

# good number strings:
my @good = [
 "32 01 64 02 42 01",                     # 0, n = 6
 "32 01 64 02 42 01 2025-09-06",          # 1, n = 7
 "32 01 64 02 42 01 2025-09-06 dp",       # 2, n = 8
 "32 01 64 02 42 01 2025-09-06 2x",       # 3, n = 8
 "32 01 64 02 42 01 2025-09-06 pp",       # 4, n = 8
 "32 01 64 02 42 01 2025-09-06 qp",       # 5, n = 8
 "32 01 64 02 42 01 2025-09-06 pp dp qp", # 6, n = 10
];

for @good.kv -> $i, $n {
    lives-ok {
        %h = Lstr2info-hash $n; 
    }, "good input: $n";

    my $N = $n.words.elems;
    with $i { 
        when * == 0 { is $N, 6 }
        when * == 1 { is $N, 7 }
        when * == 6 { is $N, 10 }
        default     { is $N, 8 }
    }
}

# bad number strings:
my @bad = [
 "32 01 64 02 42 27",            # 0, n = 6
 "32 01 70 02 42 01 2025-09-06", # 1, n = 7
];

for @bad.kv -> $i, $n {
    lives-ok {
        %h = Lstr2info-hash $n; 
    }, "bad input: $n";

    my $N = $n.words.elems;
    with $i { 
        when * == 0 { is $N, 6 }
        when * == 1 { is $N, 7 }
    }
}

done-testing;
