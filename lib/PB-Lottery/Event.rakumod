unit class PB-Lottery::Event;

use Text::Utils :strip-comment, :str2intlist;

use PB-Lottery::Draw;
use PB-Lottery::Ticket;

has $.draw of PB-Lottery::Draw      is required;
has @.tickets of PB-Lottery::Ticket is required;

has $.date;

has @.valid-tickets of PB-Lottery::Ticket is built;

submethod TWEAK {
    $!date = $!draw.date;
    # eliminate tickets paid or out of date
    for @!tickets -> $t {
        my $valid-date = $t.date;
        my $paid = $t.paid;
        next if $t.paid;
        next if $valid-date < $!date;
        @!valid-tickets.push: $t;
    }
}

method show(:$all, :$debug) {
    my $d = $!draw;

    # $e.draw.print1; print " | "; $e.draw.print2; say();

    # sort the tickets by winnings if more than one
    if @!valid-tickets.elems > 1 {
        say "NOTE: Multiple tickets are not yet sorted by winnings...";
        say "      File an issue if that is desired.";
    }

    for @!valid-tickets -> $t {
        die "FATAL: not a Ticket" unless $t ~~ PB-Lottery::Ticket;
        self!show-matches: :draw($!draw), :ticket($t);

#       $d.print1; print " | "; $t.print1; say();
#       $d.print2; print " | "; $t.print2; say();
    }
}

method !show-matches(
    :$draw!,
    :$ticket!,
) {

    # show the draw/ticket in two columns
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    #                        --    --
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    #                     --    --                      
    # where the "--" (or other suitable double char) indicates
    #   a match of that ticket's numbers with those of the
    #   draw's power ball's  or double play's numbers

    my $d = $draw;
    my $Lset1a = $d.N.numbers5; 
    my $Lset1b = $d.N.pb; 
    my $Lset2a = $d.N2.numbers5; 
    my $Lset2b = $d.N2.pb; 

    my $t = $ticket;
    my $Rset1a = $t.N.numbers5; 
    my $Rset1b = $t.N.pb; 

    my $Rset2a = $t.N.numbers5; 
    my $Rset2b = $t.N.pb; 

    # get the intersection of the numbers5 and pb for each set
    my $FRset1a = $Lset1a (&) $Rset1a;
    my $FRset1b = $Lset1b (&) $Rset1b;
    my $FRset2a = $Lset2a (&) $Rset2a;
    my $FRset2b = $Lset2b (&) $Rset2b;
 
    # those intersections determine which RHS numbers get an "underline" character
}

