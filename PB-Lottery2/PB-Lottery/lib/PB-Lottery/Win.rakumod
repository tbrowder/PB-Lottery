unit module PB::Lottery::Win;

class Win is export {
    has $.pb    is rw = 0;  # power ball winnings (base, no power play factor)
    has $.pp    is rw = 0;  # additional winnings due to the power play factor
                            # (always zero unless the ticket selected that option)
    has $.dp    is rw = 0;  # additional winnings due to the double play option
                            # (always zero unless the ticket selected that option)

    method total() {
        $!pb + $!pp + $!dp
    }
}
