use Test;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;

isa-ok PB-Lottery, PB-Lottery;

# miscellanous checks of subs and classes
my ($n1, $n2, $n3);
my ($e1, $e2, $e3);
my (%h);

# good number strings:
$n1 = "32 01 64 02 42 01";
$e1 = 6;
$n2 = "32 01 64 02 42 01 2025-09-06 3x";
$e2 = 8;
$n3 = "32 01 64 02 42 01 2025-09-06 dp";
$e3 = 8;

for ($n1, $n2, $n3).kv -> $i, $n {
    lives-ok {
        %h = Lstr2info-hash $n; 
    }, "good input: $n";

    my $N = $n.words.elems;
    with $i { 
        when * == 0 { is $N, 6 }
        when * == 1 { is $N, 8 }
        when * == 2 { is $N, 8 }
    }
}

# bad number strings:
$n1 = "32 01 64 02 42 27";
$e1 = 6;
$n2 = "32 01 70 02 42 01 2025-09-06";
$e2 = 7;

for ($n1, $n2).kv -> $i, $n {
    lives-ok {
        %h = Lstr2info-hash $n; 
    }, "bad input: $n";

    my $N = $n.words.elems;
    with $i { 
        when * == 0 { is $N, 6 }
        when * == 1 { is $N, 7 }
    }
}

# from the docs:
sub saruman(Bool :$ents-destroy-isengard) {
    die "Killed by Wormyongue" if $ents-destroy-isengard;
}

dies-ok {
    saruman(ents-destroy-isengard => True), "Saruman dies";
}

done-testing;
