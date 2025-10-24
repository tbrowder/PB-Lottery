#!/usr/bin/env raku
use JSON::Fast;
use HTTP::UserAgent;

# NY Open Data Powerball endpoint (national draws)
my $endpoint = 'https://data.ny.gov/resource/d6yy-54nr.json?$limit=1&$order=draw_date%20DESC';

my $ua = HTTP::UserAgent.new;
my $resp = $ua.get($endpoint);
die "HTTP error: {$resp.status-line}" unless $resp.is-success;

my @rows = from-json $resp.content;
die "No data returned" if @rows.elems == 0;

my %row = @rows[0].Hash;

# Typical fields:
# draw_date (e.g., "2025-10-11T00:00:00.000"), winning_numbers ("n1 n2 n3 n4 n5 PB"), multiplier ("2")
my $draw-date = (%row<draw_date> // '').substr(0, 10);
my @parts     = (%row<winning_numbers> // '').split(/\s+/);
die "Unexpected winning_numbers format" unless @parts.elems >= 6;

my @white = @parts[0..4].map(*.Int);
my $pb    = @parts[5].Int;
my $mult  = %row<multiplier> // Any;

my %out = (
  draw_date   => $draw-date,
  numbers     => @white,
  powerball   => $pb,
  multiplier  => $mult.defined ?? $mult !! Nil,
  source      => 'data.ny.gov',
  jackpot_usd => Nil,  # You can augment via MUSL or powerball.com if desired
);

say to-json %out, :pretty;
