unit class PB-Lottery::Draw;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment, :str2intlist;

use PB-Lottery::Numbers;
use PB-Lottery::Subs;
use PB-Lottery::Vars;

my $debug = 0;

has Str $.numbers-str  is required;
has Str $.numbers-str2 is required;

has Date $.date;
has      $.nx;          # is required as part of the main draw
has      $.jackpot = 0; # optional, but desired

has Str  $.type;
has Str  $.type2;

has PB-Lottery::Numbers $.N;  # fill in TWEAK
has PB-Lottery::Numbers $.N2; # fill in TWEAK

method print1(:$debug) {
    # called by an Event object
    my $s = self.N.numbers-str;
    if $debug {
        say "debug: {self.N.numbers-str}";
        exit(1);
    }
    print $s;
}
method print2() {
    # called by an Event object
    my $s = self.N2.numbers-str;
    print $s;
}

submethod TWEAK {
    my @w  = $!numbers-str.words;
    my @w2 = $!numbers-str2.words;

    my $s;
    $s   = @w[0..^6].join(' '); # only want first six numbers
    $!N  = PB-Lottery::Numbers.new: :numbers-str($s);

    $s   = @w2[0..^6].join(' '); # only want first six numbers
    $!N2 = PB-Lottery::Numbers.new: :numbers-str($s);

    # required date
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

    # optional jackpot value for the power ball drae
    if @w.elems > 8 {
        my $jp = @w[8];
        $!jackpot = get-dollars $jp;
    }

    $!type2 = @w2[7];
    unless $!type !=== $!type2 {
        my $msg = "The two types should NOT be the same: '$!type', '$!type2'";
        throw-err $msg;
    }
}
