unit class PB-Lottery::Numbers;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment, :str2intlist;

constant MAX-NUM = 69;
constant MAX-PB  = 26;

                                     #  0  1  2  3  4  5 <= index
has Str  $.numbers-str is required;  # "00 00 00 00 00 00";
has List $.numbers5 is built; # the five lottery numbers
has Int  $.pb is built; # the powerball

submethod TWEAK {
    my $s1 = $!numbers-str.words[0..^5].join(" ");
    my $s2 = $!numbers-str.words[5];
    my @n = str2intlist $s1;
    my @p = str2intlist $s2;
    $!numbers5 = @n;
    $!pb = @p.head;

    self!validate;
}

method !validate() {
    # subset Number    of Int where 1..69;
    # subset Powerball of Int where 1..26;

    my $err1 = 0;
    my $err2 = 0;

    for self.numbers5 -> $n {
        unless 0 < $n <= MAX-NUM { ++$err1; }
    }
    unless 0 < self.pb <= MAX-PB { ++$err2; }

}

=begin comment
method print1() {
    # show
    # nn nn nn nn nn nn
    # --    --           # <== matches
}
=end comment
