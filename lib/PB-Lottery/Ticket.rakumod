unit class PB-Lottery::Ticket;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;
use PB-Lottery::Numbers;

has Str  $.numbers-str is required;
has Date $.date;

has PB-Lottery::Numbers $.N; # fill in TWEAK

has      %.numbers-hash;
has Str  $.type;
has Bool $.is-qp;

submethod TWEAK {
    my $s  = $!numbers-str;
    unless $s ~~ /\S/ {
        my $msg = "Cannot create a PB-Draw object with an empty input string";
        throw-err $msg;
    }
    %!numbers-hash = create-numhash $s, :is-ticket(True);
    $!date = Date.new: %!numbers-hash<DATE>;
    $!type = %!numbers-hash<TYPE>;

    $s = $s.words[0..^6].join(' '); # only want first six numbers
    $!N  = PB-Lottery::Numbers.new: :numbers-str($s);
}
