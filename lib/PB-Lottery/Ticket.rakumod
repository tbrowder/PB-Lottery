unit class PB-Lottery::Ticket;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment, :str2intlist;

need PB-Lottery::Numbers;
need PB-Lottery::Win;
use PB-Lottery::Subs;
use PB-Lottery::Vars;

has Str  $.numbers-str is required;

has Date $.date is built;

has Str  $.type is built;
has Bool $.is-qp;
has Bool $.paid = False;
has Bool $.pp = False;
has Bool $.dp = False;
 
has PB-Lottery::Numbers $.N; # fill in TWEAK

has @.numbers; 
has $.powerball;

submethod TWEAK {
    unless $!numbers-str ~~ /\S/ {
        my $msg = "Cannot create a Ticket object with an empty";
        $msg ~= " input string";
        throw-err $msg;
    }

    my @w  = $!numbers-str.words;
    $!date = Date.new: @w[6];
    $!type = @w[7];

# new 
    for @w[0..^5] -> $n is copy {
        if $n.chars == 2 and $n.comb.head eq '0' {
            $n = $n.comb.tail.Int;
        }
    }
    @!numbers   = @w[0..^5].Int;
    $!powerball = @w[5].Int;
  
    my $s  = @w[0..^6].join(' '); # only want first six numbers
    $!N    = PB-Lottery::Numbers.new: :numbers-str($s);

    if $!numbers-str ~~ /:i paid / {
        $!paid = True;
    }
    if $!numbers-str ~~ /:i db / {
        $!dp = True;
    }
    if $!numbers-str ~~ /:i pp / {
        $!pp = True;
    }
}

method print1() {
    # called by an Event object
    my $s = self.N.numbers-str;
    print $s;
}

method print2() {
    # called by an Event object
    my $s = self.N.numbers-str;
    print $s;
}
