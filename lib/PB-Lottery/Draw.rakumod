unit class PB-Lottery::Draw;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;
use PB-Lottery::Numbers;

has Str $.numbers-str  is required;
has Str $.numbers-str2 is required;

has Date $.date;
has Str  $.type;
has      $.jackpot; # optional

has PB-Lottery::Numbers $.N;  # fill in TWEAK
has PB-Lottery::Numbers $.N2; # fill in TWEAK

=begin comment
# don't need the hash for a Draw, do it all in TWEAK
has      %.numbers-hash;
has      %.numbers-hash2;
=end comment

has $debug = 0;

submethod TWEAK {
    my @w  = $!numbers-str.words;
    my @w2 = $!numbers-str2.words;

    my $s;
    $s   = @w[0..^6].join(' '); # only want first six numbers
    $!N  = PB-Lottery::Numbers.new: :numbers-str($s);

    $s   = @w2[0..^6].join(' '); # only want first six numbers
    $!N2 = PB-Lottery::Numbers.new: :numbers-str($s);

#   %!numbers-hash  = create-numhash $s,  :$debug;
#   %!numbers-hash2 = create-numhash $s2, :$debug;

#   $!date = Date.new: %!numbers-hash<DATE>; # the seventh word in each string
#                                            #   (are they the same in each string?)
    $!date = Date.new: @w[6];
    my $d2 = Date.new: @w2[6];

#   $!type = %!numbers-hash<TYPE>;           # the eighth word in each string
#                                            #   (are they the same in each string?)
    $!type = @w[7];
    my $t2 = @w2[7];
}
