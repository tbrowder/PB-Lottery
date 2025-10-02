unit class PB-Lottery::Ticket;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;

has Str  $.numbers-str is required;

has      %.numbers-hash;
has Date $.date;
has Str  $.type;

has Bool $.is-qp;

submethod TWEAK {
    unless $!numbers-str ~~ /\S/ {
        my $msg = "Cannot create a PB-Ticket object with an empty input string";
        throw-err $msg;
    }
    %!numbers-hash = create-numhash $!numbers-str, :is-ticket(True);
    $!date = Date.new: %!numbers-hash<DATE>;
    $!type = %!numbers-hash<TYPE>;
}
