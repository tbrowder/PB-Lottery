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
has Str  $.dow; # day of the week 

has PB-Lottery::Numbers $.N;  # fill in TWEAK
has PB-Lottery::Numbers $.N2; # fill in TWEAK

# from ChatGPT:
has @.numbers of Array;
has $.powerball where * < 0 < 27;
has @.double-numbers;
has $.double-powerball where * < 0 < 27;

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

    $!type2 = @w2[7];

    # collect the remaining pieces of @w and then figure out 
    # what we have:

    # dow, Nx (also $!type), dollars
    for @w[7..*] -> $s  {
        when $s ~~ /^:i \h* (\d+) x \h* $/ {
            # Nx
            $!nx = +$0.UInt;
            unless $!nx ~~ /2|3|4|5|10/ {
                my $msg = "Power Play factor '$!nx' should be ";
                $msg ~= "2, 3, 4, 5, or 10";
                die $msg;
            }
        }
        when $s ~~ /^:i \h* (mon|wed|sat) \h* $/ {
            # dow
            $!dow = ~$0.tc;
        }
        when $s ~~ /^:i \h* (\$? \d+ [m|b|t]? )/ {
            $!jackpot = get-dollars $s;
        }
        default {
            die qq:to/HERE/;
            FATAL: Unrecognized word '$s' in the Power Ball draw line:
              the full line: |$!numbers-str|
            HERE
        }
    }

    =begin comment
    $!type  = @w[7]; # the Nx factor
    $!nx    = @w[7];
    if  $!type ~~ /^:i \h* (\d+) x \h* $/ {
        $!nx = +$0.UInt;
        unless $!nx ~~ /2|3|4|5|10/ {
            my $msg = "Power Play factor '$!nx' should be ";
            $msg ~= "2, 3, 4, 5, or 10";
            die $msg;
        }
    }
    else {
        die qq:to/HERE/;
        Power Play factor not determined in type string '$!type'
          the full line: |$!numbers-str|
        HERE
    }

    # optional jackpot value for the power ball draw
    if @w.elems > 8 {
        my $jp = @w[8];
        $!jackpot = get-dollars $jp;
    }

    $!type2 = @w2[7];
    unless $!type !=== $!type2 {
        my $msg = "The two types should NOT be the same:\n";
        $msg ~= " '$!type', '$!type2'";
        throw-err $msg;
    }
    =end comment
}
