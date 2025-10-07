use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;

my $debug = 0;

is 1, 1, "sanity check";

my (%pb, %pp, %dp);
for @power-ball-prizes.kv -> $i, $s {
    if $s ~~ /^ n '/' a / {
        say "non-numeric value: |$s|"; 
    }
    if $s ~~ /^ jackpot / {
        say "non-numeric value: |$s|"; 
    }
    say "pb string: |$s|";
    my @w = $s.words;
    my $k = @w.head;
    my $v = @w.tail;
    say "  its key/value: |$k| => |$v|";
    %pb{$k} = $v;
}
for @power-play-prizes.kv -> $i, $s {
    if $s ~~ /^ n '/' a / {
        say "non-numeric value: |$s|"; 
    }
    if $s ~~ /^ jackpot / {
        say "non-numeric value: |$s|"; 
    }
    say "pp string: |$s|";
    my @w = $s.words;
    my $k = @w.head;
    my $v = @w.tail;
    say "  its key/value: |$k| => |$v|";
    %pp{$k} = $v;
}
for @double-play-prizes.kv -> $i, $s {
    if $s ~~ /^ n '/' a / {
        say "non-numeric value: |$s|"; 
    }
    if $s ~~ /^ jackpot / {
        say "non-numeric value: |$s|"; 
    }
    say "dp string: |$s|";
    my @w = $s.words;
    my $k = @w.head;
    my $v = @w.tail;
    say "  its key/value: |$k| => |$v|";
    %dp{$k} = $v;
}

say "\%pb hash:";
for %pb.kv -> $k, $v {
    say "  key/value: |$k| => |$v|";
}

say "\%dp hash:";
for %dp.kv -> $k, $v {
    say "  key/value: |$k| => |$v|";
}

say "\%pp hash:";
for %pp.kv -> $k, $v {
    say "  key/value: |$k| => |$v|";
}

done-testing;


