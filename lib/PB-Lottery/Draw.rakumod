unit class PB-Lottery::Draw;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;
use PB-Lottery::Numbers;

has Str $.numbers-str  is required;
has Str $.numbers-str2 is required;

has Date $.date;

has PB-Lottery::Numbers $.N;  # fill in TWEAK
has PB-Lottery::Numbers $.N2; # fill in TWEAK

has      %.numbers-hash;
has      %.numbers-hash2;
has Str  $.type;

has $debug = 0;

submethod TWEAK {
    my $s  = $!numbers-str;
    my $s2 = $!numbers-str2;

    %!numbers-hash  = create-numhash $s,  :$debug;
    %!numbers-hash2 = create-numhash $s2, :$debug;
    $!type = %!numbers-hash<TYPE>;
    $!date = Date.new: %!numbers-hash<DATE>;

    $s = $s.words[0..^6].join(' '); # only want first six numbers
    $!N  = PB-Lottery::Numbers.new: :numbers-str($s);

    $s2  = $s2.words[0..^6].join(' '); # only want first six numbers
    $!N2 = PB-Lottery::Numbers.new: :numbers-str($s2);
}
