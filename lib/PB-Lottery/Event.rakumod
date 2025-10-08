unit class PB-Lottery::Event;

use PB-Lottery::Draw;
use PB-Lottery::Ticket;

has $.draw of PB-Lottery::Draw      is required;
has @.tickets of PB-Lottery::Ticket is required;

has $.date;

submethod TWEAK {
    $!date = $!draw.date;
    # sort the tickets by winnings
}

method show {
    # show the draw/ticket in two columns
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    #                        --    --
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    #                     --    --                      
    for @!tickets -> $t {
        self.draw.print1; $t.print1;
        self.draw.print2; $t.print2;
    }
}

