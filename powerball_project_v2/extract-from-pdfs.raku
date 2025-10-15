#!/usr/bin/env raku
use v6;
use JSON::Fast;

# extract-from-pdfs.raku
# Walk one or more PDFs / directories / globs, parse with pdftotext,
# merge results by date, and emit blocks and/or JSON.
#
# Requires: pdftotext (poppler-utils).

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

sub parse-pdf(IO::Path $pdf --> Hash) {
    my $txt = $*TMPDIR.IO.add("pb-" ~ $pdf.basename ~ ".txt");
    my $pt = run 'pdftotext', '-layout', '-q', $pdf, $txt, :out, :err;
    die "pdftotext failed for {$pdf}" if $pt.exitcode != 0;
    my %by-date = Hash[Hash].new;

    for $txt.open(:r, :enc('utf8-c8')).lines -> $line {
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

    return %by-date;
}

sub expand-args(*@args --> Seq) {
    gather for @args -> $arg {
        my $p = $arg.IO;
        if $p.d {
            for $p.dir -> $f {
                take $f if $f.f and $f.extension.lc eq 'pdf';
            }
        }
        elsif $arg ~~ /[*?]/ {
            my $dir = $p.dirname.IO;
            for $dir.dir -> $f {
                take $f if $f.basename ~~ $p.basename and $f.extension.lc eq 'pdf';
            }
        }
        elsif $p.f and $p.extension.lc eq 'pdf' {
            take $p;
        }
    }
}

sub MAIN(
    *@pdfs,                                  #= PDFs, dirs, or globs
    :$emit = 'blocks',                       #= blocks|json|both
) {
    # Ensure pdftotext is available
    my $which = run 'bash', '-lc', 'command -v pdftotext', :out, :err;
    die "pdftotext not found (install poppler-utils)" if $which.exitcode != 0;

    my @files = expand-args(|@pdfs);
    die "No PDFs found from arguments" unless @files;

    my %merged = Hash[Hash].new;
    for @files.sort(*.basename) -> $pdf {
        my %d = parse-pdf($pdf);
        for %d.kv -> $date, %kinds {
            %merged{$date} //= {};
            for %kinds.kv -> $kind, $rec {
                %merged{$date}{$kind} = $rec;  # last wins
            }
        }
    }

    my @dates = %merged.keys.sort;
    my @json;

    for @dates -> $d {
        if %merged{$d}:exists('pb') {
            my $r = %merged{$d}{'pb'};
            say fmt-block($r.nums, $r.pb, $d, $r.mult) if $emit eq 'blocks' or $emit eq 'both';
            @json.push: {
                draw_date   => $d,
                numbers     => $r.nums,
                powerball   => $r.pb,
                multiplier  => $r.mult.chars ?? $r.mult !! Nil,
                source      => 'floridalottery',
                jackpot_usd => Nil,
            } if $emit eq 'json' or $emit eq 'both';
        }
        if %merged{$d}:exists('dp') {
            my $r = %merged{$d}{'dp'};
            say fmt-block($r.nums, $r.pb, $d, 'dp') if $emit eq 'blocks' or $emit eq 'both';
            @json.push: {
                draw_date   => $d,
                numbers     => $r.nums,
                powerball   => $r.pb,
                multiplier  => Nil,
                source      => 'floridalottery dp',
                jackpot_usd => Nil,
            } if $emit eq 'json' or $emit eq 'both';
        }
    }

    if $emit eq 'json' or $emit eq 'both' {
        say to-json @json, :pretty;
    }
}
