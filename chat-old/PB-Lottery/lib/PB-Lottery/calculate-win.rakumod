unit module PB::Lottery::Calculate;

use PB::Lottery::Win :ALL;

#---------------------------------------------------------------------
# NOTE TO U.S. DEVELOPERS:
# Raku supports Unicode set operators (∩ ∪ ∖ ⊖ ⊂ ⊃ ⊆ ⊇), but they are
# hard to see and type on U.S. keyboards.  The following ASCII forms
# are exact equivalents and are recommended for readability and ease
# of entry in code and terminals:
#
#   (&)   intersection         # same as ∩
#   (|)   union                # same as ∪
#   (-)   difference           # same as ∖
#   (^)   symmetric difference # same as ⊖
#   (<)   proper subset        # same as ⊂
#   (<)=  subset or equal      # same as ⊆
#   (>)   proper superset      # same as ⊃
#   (>)=  superset or equal    # same as ⊇
#
# Example:
#   my $count = (@a (&) @b).elems;   # count common elements
#
# The parentheses are required for ASCII forms.
#---------------------------------------------------------------------

# Calculates winnings for a given Ticket and Draw.
# Returns a Win object with pb, pp, dp, and total() accessors.
sub calculate-win($ticket, $draw --> Win) is export {
    my $win = Win.new;

    # count matching regular numbers
    my $match-count = ($ticket.numbers (&) $draw.numbers).elems;
    my $pb-match    = $ticket.powerball == $draw.powerball;

    # base Powerball payout table (USD, without Power Play)
    my %payouts = (
        5 => { True  => 1_000_000_000, False => 1_000_000 },  # Jackpot
        4 => { True  => 50_000,         False => 100 },
        3 => { True  => 100,            False => 7 },
        2 => { True  => 7,              False => 0 },
        1 => { True  => 4,              False => 0 },
        0 => { True  => 4,              False => 0 },
    );

    if %payouts{$match-count}:exists {
        $win.pb = %payouts{$match-count}{$pb-match} // 0;
    }

    # apply Power Play multiplier (2–10x except on jackpot)
    if $ticket.power-play and $win.pb > 0 and $win.pb < 1_000_000_000 {
        my $multiplier = $draw.power-play // 2;  # or actual draw’s multiplier
        $win.pp = $win.pb * ($multiplier - 1);
    }

    # handle Double Play if applicable
    if $ticket.double-play and $draw.^can('double-numbers') {
        my $dmatch = ($ticket.numbers (&) $draw.double-numbers).elems;
        my $dpb    = $ticket.powerball == $draw.double-powerball;

        my %dp-payouts = (
            5 => { True  => 10_000_000, False => 500_000 },
            4 => { True  => 50_000,     False => 500 },
            3 => { True  => 500,        False => 20 },
            2 => { True  => 20,         False => 0 },
            1 => { True  => 10,         False => 0 },
            0 => { True  => 7,          False => 0 },
        );

        if %dp-payouts{$dmatch}:exists {
            $win.dp = %dp-payouts{$dmatch}{$dpb} // 0;
        }
    }

    return $win;
}
