#!/usr/bin/env raku
use v6;
use JSON::Fast;
use DateTime::Parse;
use LibCurl::Easy;   # direct-to-file download

# Emits lines like:
# 15 29 64 66 67 04 2025-09-20 Sat 2x
# 02 22 34 57 66 25 2025-09-20 Sat dp
#
# - Weekday is ALWAYS appended.
# - Suffix: "2x".."10x" for Power Play; "dp" for Double Play.
# - --emit=blocks|json|both controls output. JSON uses the normalized schema.
# - If :pdf is provided, parse that local PDF; otherwise fetch :pdf-url to a temp file.
# - Requires: pdftotext (poppler-utils).

sub iso-to-weekday(Str $iso --> Str) {
    my ($y, $m, $d) = $iso.split('-')».Int;
    my $dt = DateTime.new(:$y, :$m, :$d);
    return <Mon Tue Wed Thu Fri Sat Sun>[$dt.day-of-week - 1];
}

sub fmt-block(@white, Int $pb, Str $date, Str $suffix --> Str) {
    my @w = @white.map({ sprintf "%02d", $_ });
    my $pbp = sprintf "%02d", $pb;
    my $dow = iso-to-weekday($date);
    my $tail = $suffix.chars ?? " $suffix" !! '';
    return "{@w.join(' ')} {$pbp} {$date} {$dow}{$tail}";
}

sub parse-mmddyy(Str $mdy --> Str) {
    my @p = $mdy.split('/');
    die "bad date $mdy" unless @p.elems == 3;
    my ($m, $d, $y2) = @p».Int;
    my $y = 2000 + $y2;
    return sprintf "%04d-%02d-%02d", $y, $m, $d;
}

class Rec {
    has Str  $.date;
    has @.nums;
    has Int  $.pb;
    has Str  $.mult is rw;
    has Bool $.is-dp = False;
}

sub MAIN(
    :$last = 10,                                           #= most recent N dates
    :$since = '',                                          #= inclusive ISO start
    :$until = '',                                          #= inclusive ISO end
    :$emit = 'blocks',                                     #= blocks|json|both
    :$pdf  = '',                                           #= local PDF path (optional)
    :$pdf-url = 'https://files.floridalottery.com/exptkt/pb.pdf',  #= default source
) {
    if ($last <= 0) and ($since eq '' and $until eq '') {
        say q:to/USAGE/;
Usage:
  raku emit-blocks.raku --last=N [--emit=blocks|json|both]
  raku emit-blocks.raku --since=YYYY-MM-DD [--until=YYYY-MM-DD] [--emit=...]
  raku emit-blocks.raku --pdf=/path/to/pb.pdf --last=N
USAGE
        exit 2;
    }

    # Ensure pdftotext is available
    my $which = run 'bash', '-lc', 'command -v pdftotext', :out, :err;
    die "pdftotext not found (install poppler-utils)" if $which.exitcode != 0;

    # Acquire PDF: local or remote (download straight to file)
    my $pdf-file = $*TMPDIR.IO.add('pb.pdf');
    if $pdf ne '' {
        $pdf-file = $pdf.IO;          # use provided local file
    }
    else {
        my $curl = LibCurl::Easy.new(
            URL      => $pdf-url,
            download => $pdf-file.Str
        );
        $curl.perform;
    }

    # Convert to text
    my $txt-file = $*TMPDIR.IO.add('pb.txt');
    my $pt = run 'pdftotext', '-layout', '-q', $pdf-file, $txt-file, :out, :err;
    die "pdftotext failed" if $pt.exitcode != 0;

    # Tolerant UTF-8
    my @lines = $txt-file.open(:r, :enc('utf8-c8')).lines;

    my %by-date = Hash[Hash].new;

    for @lines -> $line {
        next unless $line ~~ /^ \s* (\d+ '\/' \d+ '\/' \d+) \s+ /;
        my $date = parse-mmddyy($0.Str);

        my @n = $line.comb(/\d+/);
        next if @n.elems < 9;                   # need mm dd yy + 5 whites + PB

        my @white = @n[3..7]».Int;
        my $pb    = @n[8].Int;
        my $mult  = '';

        if $line ~~ / <[Xx]> (\d+) / {
            $mult = $0.Str ~ 'x';               # X2 -> 2x
        }

        my $L = $line.uc.subst(/\s+/, ' ', :g); # collapse spaces
        my $is-dp = $L.contains('POWERBALL DP') or $L.contains('DOUBLE PLAY');

        my $rec = Rec.new(:date($date), :nums(@white), :pb($pb), :mult($mult), :is-dp($is-dp));
        %by-date{$date} //= {};
        %by-date{$date}{ $is-dp ?? 'dp' !! 'pb' } = $rec;
    }

    # Select dates
    my @dates = %by-date.keys.sort;
    if $last > 0 and @dates.elems > $last {
        @dates = @dates[* - $last .. *];
    }
    if $since ne '' {
        @dates = @dates.grep(* ge $since);
    }
    if $until ne '' {
        @dates = @dates.grep(* le $until);
    }

    # Emit
    my @json;
    for @dates -> $d {
        if %by-date{$d}:exists('pb') {
            my $r = %by-date{$d}{'pb'};
            if $emit eq 'blocks' or $emit eq 'both' {
                say fmt-block($r.nums, $r.pb, $d, $r.mult);
            }
            if $emit eq 'json' or $emit eq 'both' {
                @json.push: {
                    draw_date   => $d,
                    numbers     => $r.nums,
                    powerball   => $r.pb,
                    multiplier  => $r.mult.chars ?? $r.mult !! Nil,
                    source      => 'floridalottery',
                    jackpot_usd => Nil,
                };
            }
        }

        if %by-date{$d}:exists('dp') {
            my $r = %by-date{$d}{'dp'};
            if $emit eq 'blocks' or $emit eq 'both' {
                say fmt-block($r.nums, $r.pb, $d, 'dp');
            }
            if $emit eq 'json' or $emit eq 'both' {
                @json.push: {
                    draw_date   => $d,
                    numbers     => $r.nums,
                    powerball   => $r.pb,
                    multiplier  => Nil,
                    source      => 'floridalottery dp',
                    jackpot_usd => Nil,
                };
            }
        }
    }

    if $emit eq 'json' or $emit eq 'both' {
        say to-json @json, :pretty;
    }
}
