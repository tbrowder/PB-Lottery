unit class PB-Lottery::Numbers;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Subs;
use PB-Lottery::Vars;

has Str $.numbers-str is required;  # "00 00 00 00 00 00";

has Set $.numbers5 is built; # the five lottery numbers
has Set $.pb       is built; # the powerball

submethod TWEAK {
    my $s = $!numbers-str;
    $s = $s.words[0..^6].join(' ');
    my @w      = str2intlist $s;
    $!pb       = @w.pop.Set;
    $!numbers5 = @w.Set;

    =begin comment
    =end comment
}
