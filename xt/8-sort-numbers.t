use Test;

use Text::Utils :strip-comment;

use PB-Lottery;
use PB-Lottery::Subs;
use PB-Lottery::Vars;

my ($env-var, $pdir);

# First data line: |09 12 22 41 61 25 2025-08-27 4x|

# good tests
%*ENV<PB_LOTTERY_PRIVATE_DIR> = "t/data/good";
$env-var = "PB_LOTTERY_PRIVATE_DIR";
$pdir    = %*ENV{$env-var}; # hack

my $all   = 0;
my $debug = 0;

my $tline;
my @lines = "$pdir/draws.txt".IO.slurp.lines;
for @lines -> $line is copy {
    $line = strip-comment $line;
    $line .= trim;
    next unless $line ~~ /\S/;
    $tline = $line;
    last;
}

say "First data line: |$tline|";
my @w = $tline.words;
my @dw;
say "Words:" if $debug;
for @w -> $w is copy {
    $w .= trim;
    say "  word: |$w|" if $debug;
    my $d = trim-leading-zeros $w;
    $d .= Int;
    @dw.push($d) if $d ~~ Numeric;
}

@w .= sort;
if 0 or $debug {
    say "Words sorted alphabetically:";
    say "  word: |$_|" for @w;
}
@dw .= sort;
if 0 or $debug {
    say "Numbers sorted alphabetically:";
    say "  word: |$_|" for @dw;
}

@dw .= sort({$^a cmp $^b});
for @dw {
    isa-ok $_, Numeric
}

if 0 or $debug {
    say "Numbers sorted numerically:";
    say "  word: |$_|" for @dw;
}

@dw .= sort({$^a <=> $^b});
if 0 or $debug {
    say "Numbers sorted numerically:";
    say "  word: |$_|" for @dw;
}

for @dw {
    isa-ok $_, Numeric
}

done-testing;
