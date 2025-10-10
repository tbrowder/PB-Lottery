unit class PB-Lottery::Event;

use Text::Utils :strip-comment, :str2intlist;

use PB-Lottery::Draw;
use PB-Lottery::Ticket;

has $.draw of PB-Lottery::Draw      is required;
has @.tickets of PB-Lottery::Ticket is required;

has $.date;

has @.valid-tickets;

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

    # show the draw/ticket in two columns
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    #                        --    --
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    #                     --    --                      

    # sort the tickets by winnings if more than one
    if @!valid-tickets.elems > 1 {
        say "NOTE: Multiple tickets are not yet sorted by winnings...";
        say "      File an issue if that is desired.";
    }

    for @!valid-tickets -> $t {
        self.show-matches :draw($!draw), :ticket($t);
        next;

        $d.print1; print " | "; $t.print1; say();
        $d.print2; print " | "; $t.print2; say();
    }
}

method show-matches(
    :$draw,
    :$ticket,
) {
}

