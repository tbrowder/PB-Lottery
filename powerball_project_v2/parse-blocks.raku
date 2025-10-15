#!/usr/bin/env raku
use v6;
use JSON::Fast;
use Getopt::Long;

my Str $in  = '-';
my Str $out = '-';

get-options('in=s' => $in, 'out=s' => $out);

sub clean(Str $line --> Str) {
    return $line.subst(/\s+ '#' .* $/, '', :g).trim;
}

sub parse-line(Str $line --> Hash) {
    my $s = clean($line);
    if $s ~~ /^ \s* (\d**1..2) \s+    # 0
                    (\d**1..2) \s+    # 1
                    (\d**1..2) \s+    # 2
                    (\d**1..2) \s+    # 3
                    (\d**1..2) \s+    # 4
                    (\d**1..2) \s+    # 5
                    (\d**4) '-' (\d**2) '-' (\d**2) \s+  # yyyy mm dd # 6, 7, 8
                    (<[A..Za..z]>1..2) # 9
#              (?: \s+ ((\d**1..2) 'x' | 'dp') )? \s* $ / {
               (\s+ ((\d**1..2) 'x' | 'dp') )? \s* $ / {
        my @white = +$0, +$1, +$2, +$3, +$4;
        my $pb    = +$5;
        my $date  = sprintf "%04d-%02d-%02d", +$6, +$7, +$8;
        my $tag   = $9 // '';

        my $mult  = $tag.ends-with('x') ?? $tag !! Nil;
        my $is-dp = $tag eq 'dp';
        return { draw_date=>$date, numbers=>@white, powerball=>$pb, suffix=>$tag,
                 multiplier=>$mult, is_double_play=>$is-dp }
    }
    else {
        fail "Bad line: $line";
    }
}

my @lines = $in eq '-' ?? $*IN.lines.slurp !! $in.IO.lines;
my @data;
for @lines -> $line {
    next if $line.trim eq '' or $line.trim.starts-with('#');
    try {
        my %row = parse-line($line);
        @data.push(%row) if %row.defined;
    }
    CATCH { default { } }
}
my $json = to-json @data, :pretty;
if $out eq '-' { say $json } else { $out.IO.spurt($json) }
