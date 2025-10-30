unit class PB-Lottery::Draw;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment, :str2intlist;

need PB-Lottery::Numbers;
need PB-Lottery::Win;
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

has @.numbers; 
has $.powerball;
has @.numbers-dp;
has $.powerball-dp; 

submethod TWEAK {
    $!numbers-str  = strip-comment $!numbers-str;
    $!numbers-str2 = strip-comment $!numbers-str2;
    #---------------------------------------------
    my $s  = $!numbers-str;
    my $s2 = $!numbers-str2;
    #-------------------------------------------------
    $!N   = PB-Lottery::Numbers.new: :numbers-str($s);
    $!N2  = PB-Lottery::Numbers.new: :numbers-str($s2);
    #--------------------------------------------------
    my @w  = $!numbers-str.words;
    my @w2 = $!numbers-str2.words;
    #--------------------------------------------------
    # these are already Int lists, ensured they are ordered:
    @!numbers      = $!N.numbers5.keys.sort({ $^a <=> $^b }); 
    @!numbers-dp   = $!N2.numbers5.keys.sort({ $^a <=> $^b }); 
    #--------------------------------------------------
    $!powerball    = $!N.pb;
    $!powerball-dp = $!N2.pb;

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

    self!validate;

} # end of submethod TWEAK

method !validate() {
    ; # ok for now
}

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
