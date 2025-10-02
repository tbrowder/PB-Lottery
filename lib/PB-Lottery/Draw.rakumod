unit class PB-Lottery::Draw;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;

has Str $.numbers-str  is required;
has Str $.numbers-str2 is required;

has      %.numbers-hash;
has      %.numbers-hash2;
has Date $.date;
has Str  $.type;

has $debug = 0;

submethod TWEAK {
    my $s  = $!numbers-str;
    my $s2 = $!numbers-str2;

    %!numbers-hash  = create-numhash $s,  :$debug;
    %!numbers-hash2 = create-numhash $s2, :$debug;
    $!date = Date.new: %!numbers-hash<DATE>;
    $!type = %!numbers-hash<TYPE>;
}
