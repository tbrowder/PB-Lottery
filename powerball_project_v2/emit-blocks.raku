#!/usr/bin/env raku
use v6;
use Getopt::Long;
use JSON::Fast;
use DateTime::Parse;

my Int $last = 10;
my Str $since = '';
my Str $until = '';
my Str $emit  = 'blocks';
my Str $pdf-url = 'https://files.floridalottery.com/exptkt/pb.pdf';

get-options('last=i' => $last, 'since=s' => $since, 'until=s' => $until, 'emit=s' => $emit);

if ($last <= 0) and ($since eq '' and $until eq '') {
    say "Usage: raku emit-blocks.raku --last=N | --since=YYYY-MM-DD [--until=YYYY-MM-DD] [--emit=blocks|json|both]";
    exit 2;
}

sub slurp-url(Str $url --> Blob) {
    my $p = Proc::Async.new('curl', '--fail', '-sSL', $url);
    my $out = Blob.new;
    $p.stdout.tap({ $out ~= .list });
    await $p.start;
    my $res = await $p;
    die "curl failed with exit {$res.exitcode}" if $res.exitcode != 0;
    return $out;
}

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

class Rec { has Str $.date; has @.nums; has Int $.pb; has Str $.mult is rw; has Bool $.is-dp = False }

my %by-date = Hash[Hash].new;

my $pdf = slurp-url($pdf-url);
my $pdf-file = $*TMPDIR.IO.add('pb.pdf');
spurt $pdf-file, $pdf;

my $txt-file = $*TMPDIR.IO.add('pb.txt');
my $pt = run 'pdftotext', '-layout', '-q', $pdf-file, $txt-file, :out, :err;
die "pdftotext failed" if $pt.exitcode != 0;
my @lines = $txt-file.slurp.lines;

for @lines -> $line {
    next unless $line ~~ /^ \s* (\d+ '\/' \d+ '\/' \d+) \s+ /;
    my $date = parse-mmddyy($0.Str);
    my @n = $line.comb(/\d+/);
    next if @n.elems < 9;
    my @white = @n[3..7]».Int;
    my $pb = @n[8].Int;
    my $mult = '';
    if $line ~~ / <[Xx]> (\d+) / {
        $mult = $0.Str ~ 'x';
    }
    my $L = $line.uc.subst(/\s+/, ' ', :g);
    my $is-dp = $L.contains('POWERBALL DP') or $L.contains('DOUBLE PLAY');
    my $rec = Rec.new(:date($date), :nums(@white), :pb($pb), :mult($mult), :is-dp($is-dp));
    %by-date{$date} //= {};
    %by-date{$date}{ $is-dp ?? 'dp' !! 'pb' } = $rec;
}

my @dates = %by-date.keys.sort;
if $last > 0 and @dates.elems > $last { @dates = @dates[* - $last .. *] }
if $since ne '' { @dates = @dates.grep(* ge $since) }
if $until ne '' { @dates = @dates.grep(* le $until) }

my @json;
for @dates -> $d {
    if %by-date{$d}:exists('pb') {
        my $r = %by-date{$d}{'pb'};
        if $emit eq 'blocks' or $emit eq 'both' { say fmt-block($r.nums, $r.pb, $d, $r.mult) }
        if $emit eq 'json' or $emit eq 'both' {
            @json.push({
                draw_date   => $d,
                numbers     => $r.nums,
                powerball   => $r.pb,
                multiplier  => $r.mult.chars ?? $r.mult !! Nil,
                source      => 'floridalottery',
                jackpot_usd => Nil,
            })
        }
    }
    if %by-date{$d}:exists('dp') {
        my $r = %by-date{$d}{'dp'};
        if $emit eq 'blocks' or $emit eq 'both' { say fmt-block($r.nums, $r.pb, $d, 'dp') }
        if $emit eq 'json' or $emit eq 'both' {
            @json.push({
                draw_date   => $d,
                numbers     => $r.nums,
                powerball   => $r.pb,
                multiplier  => Nil,
                source      => 'floridalottery dp',
                jackpot_usd => Nil,
            })
        }
    }
}
if $emit eq 'json' or $emit eq 'both' { say to-json @json, :pretty }
