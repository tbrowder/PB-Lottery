unit class PB-Lottery::Draw;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;

has Str $.numbers-str  is required;
has Str $.numbers-str2 is required;

has Date $.date;
has Str  $.type;
has Str  $.type2;
has      $.jackpot; # optional, but desired
has      $.nx;      # is required as part of the main draw

has PB-Lottery::Numbers $.N;  # fill in TWEAK
has PB-Lottery::Numbers $.N2; # fill in TWEAK

=begin comment
# don't need the hash for a Draw, do it all in TWEAK
has      %.numbers-hash;
has      %.numbers-hash2;
=end comment

has $debug = 0;

submethod TWEAK {
    my @w  = $!numbers-str.words;
    my @w2 = $!numbers-str2.words;

    my $s;
    $s   = @w[0..^6].join(' '); # only want first six numbers
    $!N  = PB-Lottery::Numbers.new: :numbers-str($s);

    $s   = @w2[0..^6].join(' '); # only want first six numbers
    $!N2 = PB-Lottery::Numbers.new: :numbers-str($s);

    $!date = Date.new: @w[6];

    my $d2 = Date.new: @w2[6];
    unless $!date === $d2 {
        my $msg = "The two dates are not the same: '$!date', '$d2'";
        throw-err $msg;
    }

    $!type  = @w[7]; # the Nx factor
    $!nx    = @w[7];
    if  $!type ~~ /^:i \h* (\d+) x \h* $/ {
        $!nx = +$0.UInt;
        unless $!nx ~~ /2|3|4|5|10/ {
            die "Power Play factor '$!nx' should be 2, 3, 4, 5, or 10";
        }
    }
    else {
        die qq:to/HERE/;
        Power Play factor not determined in type string '$!type'
          the full line: |$!numbers-str|
        HERE
    }

    $!type2 = @w2[7];
    unless $!type !=== $!type2 {
        my $msg = "The two types should NOT be the same: '$!type', '$!type2'";
        throw-err $msg;
    }
}
