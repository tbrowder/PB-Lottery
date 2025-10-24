#!/usr/bin/env raku
use v6;
use JSON::Fast;
use HTTP::UserAgent;
use Getopt::Long;

my Str $from = '';
my Str $to   = '';
my Int $last = 0;

get-options('from=s' => $from, 'to=s' => $to, 'last=i' => $last);

my Str $base = 'https://data.ny.gov/resource/d6yy-54nr.json';
my Str $query = '';

if $last > 0 {
    #$query = "?$limit={$last}&$order=draw_date%20DESC";
    $query = "?limit={$last}&order=draw_date%20DESC";
}
else {
    if $from ne '' and $to ne '' {
        $query = "?where=draw_date between '%sT00:00:00' and '%sT23:59:59'&order=draw_date"
                 . sprintf($from, $to);
    }
    else {
        note "Usage: --last=N  or  --from=YYYY-MM-DD --to=YYYY-MM-DD";
        exit 2;
    }
}

my $ua   = HTTP::UserAgent.new;
my $arg  = $base ~ $query;
#my $resp = $ua.get($base ~ $query);
my $resp = $ua.get($arg);
say "DEBUG: response query: '$arg'";
die "HTTP error: {$resp.status-line}" unless $resp.is-success;

my @rows = from-json $resp.content;
my @out;

for @rows -> %row {
    my $draw-date = (%row<draw_date> // '').substr(0, 10);
    my @p = (%row<winning_numbers> // '').split(/\s+/);
    next unless @p.elems >= 6;
    my @w  = @p[0..4].map(*.Int);
    my $pb = @p[5].Int;
    my $mult = %row<multiplier> // Any;
    @out.push: {
        :$draw-date,
        numbers     => @w,
        powerball   => $pb,
        multiplier  => $mult.defined ?? $mult !! Nil,
        source      => 'data.ny.gov',
        jackpot_usd => Nil,
    };
}
@out = @out.sort(*.<draw-date>);
say to-json @out, :pretty;
