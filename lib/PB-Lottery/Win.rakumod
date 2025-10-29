unit class PB-Lottery::Win;

has $.pb is rw = 0; # power ball winnings (without the power 
                    #   play factor
has $.pp is rw = 0; # any additional winnings due to the
                    #   power play factor (note it will always
                    #   be zero unless the ticket has
                    #   that option selected)
has $.dp is rw = 0; # any additional winnings due to the
                    #   double play option (note it will always                           #   be zero unless the ticket has that
                    #   option selected)
method total() {
    $!pb + $!pp + $!dp
}
