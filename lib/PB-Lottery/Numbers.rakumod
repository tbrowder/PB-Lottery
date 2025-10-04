unit class PB-Lottery::Numbers;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;

has Str $.numbers-str is required;  # "00 00 00 00 00 00";

has Set $.numbers5 is built; # the five lottery numbers
has Set $.pb       is built; # the powerball

submethod TWEAK {
    my $s = $!numbers-str;
    $s = $s.words[0..^6].join(' ');
    my @w      = str2intlist $s;
    $!pb       = @w.pop.Set;
    $!numbers5 = @w.Set;

    =begin comment
    my @w = $!num-str.words;
    my @a = 'a'..'f';
    for @w.kv -> $i, $v is copy {
        my $k  = @a[$i];
        my $nc = $v.chars;
        die "FATAL: str $v has other 1 or 2 chars" unless {0 < $nc < 3};
        if $v ~~ / 0 (\d) / {
            %!num-hash{$k} = +$0.UInt;
        }
        else {
            %!num-hash{$k} = $v.UInt;
        }

        # other requirements
        my $res = %!num-hash{$k};
        if $i < 5 {
            # range is 1..69
            die "FATAL: int $res is out of range 1..69" unless {0 < $res < 70}
        }
        else {
            # range is 1..26
            die "FATAL: int $res is out of range 1..26" unless {0 < $res < 27}
        }
    }
    # the first 5 numbers must be unique
    my @arr = [%!num-hash.keys<a>..%!num-hash<e>];
    =end comment
}
