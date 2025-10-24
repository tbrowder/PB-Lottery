unit module PB::Lottery::Format;

# Format utilities for two-line Powerball record blocks.
# Validates, parses, and emits draw lines.

sub parse-line(Str $line --> Hash) is export {
    # TODO: Implement strict regexes for main/dp lines and return a hash:
    # { :date(Str), :numbers(Array[Int]), :pb(Int), :type('pb'|'dp'),
    #   :multiplier(Str|Nil), :jackpot(Str|Nil) }
    ...
}

sub format-line(%rec --> Str) is export {
    # TODO: Emit canonical two-line block string from %rec
    ...
}
