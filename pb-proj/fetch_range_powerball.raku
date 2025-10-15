#!/usr/bin/env raku
use JSON::Fast;
use HTTP::UserAgent;
use Getopt::Long;

my Str $from = '';
my Str $to   = '';
my Int $last = 0;

GetOptions(
  'from=s' => \$from,
  'to=s'   => \$to,
  'last=i' => \$last,
);

my $base = 'https://data.ny.gov/resource/d6yy-54nr.json';

my $query;
if $last > 0 {
    $query = "?$limit={$last}&$order=draw_date%20DESC";
} elsif $from ne '' && $to ne '' {
    $query = "?$where=draw_date between '%sT00:00:00' and '%sT23:59:59'&$order=draw_date".sprintf($from, $to);
} else {
    note "Usage: --last=N  or  --from=YYYY-MM-DD --to=YYYY-MM-DD";
    exit 2;
}

my $ua = HTTP::UserAgent.new;
my $resp = $ua.get($base ~ $query);
die "HTTP error: {$resp.status-line}" unless $resp.is-success;

my @rows = from-json $resp.content;
my @out;

for @rows -> %row {
    my $draw-date = (%row<draw_date> // '').substr(0, 10);
    my @parts     = (%row<winning_numbers> // '').split(/\s+/);
    next unless @parts.elems >= 6;
    my @white = @parts[0..4].map(*.Int);
    my $pb    = @parts[5].Int;
    my $mult  = %row<multiplier> // Any;
    @out.push: {
        :$draw-date,
        numbers     => @white,
        powerball   => $pb,
        multiplier  => $mult.defined ?? $mult !! Nil,
        source      => 'data.ny.gov',
        jackpot_usd => Nil,
    };
}

# Sort ascending by date (ISO dates sort lexicographically)
@out = @out.sort: *.{"draw-date"} // *.{"draw_date"};

say to-json @out, :pretty;
