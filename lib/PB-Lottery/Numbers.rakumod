unit class PB-Lottery::Numbers;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment, :str2intlist;

subset Powerball of Int where 1..26;
subset Number    of Int where 1..69;

has Str $.numbers-str is required;  # "00 00 00 00 00 00";
has Set $.numbers5 is built; # the five lottery numbers
has Powerball $.pb is built; # the powerball

submethod TWEAK {
    my $s = $!numbers-str.words[0..^6].join(" ");
    my @i = str2intlist $s;
    my @n = @i[0..^5];
    $!numbers5 = @n.Set;
    $!pb = @i.tail;

    self!validate;
}

method !validate() {
    ; # okunless 
}

=begin comment
method print1() {
    # show
    # nn nn nn nn nn nn
    # --    --           # <== matches
}
=end comment
