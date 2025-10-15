#!/usr/bin/env raku
use v6;
use JSON::Fast;
sub clean(Str $line --> Str) { $line.subst(/ \s+ '#' .* $ /, '', :g).trim }
sub parse-line(Str $line --> Hash) {
    my $s = clean($line);
    if $s ~~ /^ \s* (\d**1..2) \s+ (\d**1..2) \s+ (\d**1..2) \s+ (\d**1..2) \s+ (\d**1..2) \s+ (\d**1..2) \s+ (\d**4) '-' (\d**2) '-' (\d**2) \s+ <[A..Z]><[a..z]><[a..z]> (?: \s+ ((\d**1..2) 'x' | 'dp') )? \s* $ / {
        my @white = +$0, +$1, +$2, +$3, +$4; my $pb=+$5; my $date = sprintf "%04d-%02d-%02d", +$6, +$7, +$8; my $tag = $9 // '';
        my $mult = $tag.ends-with('x') ?? $tag !! Nil; my $isdp = $tag eq 'dp';
        return { draw_date=>$date, numbers=>@white, powerball=>$pb, suffix=>$tag, multiplier=>$mult, is_double_play=>$isdp }
    } else { fail "Bad line: $line" }
}
sub MAIN(:$in='-', :$out='-') {
    my @lines = $in eq '-' ?? $*IN.lines.slurp !! $in.IO.lines; my @data;
    for @lines -> $line { next if $line.trim eq '' or $line.trim.starts-with('#'); try { my %row = parse-line($line); @data.push(%row) if %row.defined } CATCH { default { } } }
    my $json = to-json @data, :pretty; if $out eq '-' { say $json } else { $out.IO.spurt($json) }
}