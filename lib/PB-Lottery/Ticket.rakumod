unit class PB-Lottery::Ticket;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment, :str2intlist;

use PB-Lottery::Numbers;
use PB-Lottery::Subs;
use PB-Lottery::Vars;

has Str  $.numbers-str is required;
has Date $.date is built;
has Str  $.type is built;
has Bool $.is-qp;
has Bool $.paid = False;

has PB-Lottery::Numbers $.N; # fill in TWEAK

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

submethod TWEAK {
    unless $!numbers-str ~~ /\S/ {
        my $msg = "Cannot create a PB-Lottery::Ticket object with an empty input string";
        throw-err $msg;
    }

    my @w = $!numbers-str.words;
    $!date = Date.new: @w[6];
    $!type = @w[7];
  
    my $s = @w[0..^6].join(' '); # only want first six numbers
    $!N  = PB-Lottery::Numbers.new: :numbers-str($s);

    if $!numbers-str ~~ /:i paid / {
        $!paid = True;
    }
}
