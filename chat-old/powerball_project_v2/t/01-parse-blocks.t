use v6;
use Test;
use JSON::Fast;

plan 6;

my $fixture = 'tests/fixtures/sample.blocks'.IO.slurp;

# Simulate stdin usage of parse-blocks.raku by writing to a temp file first
my $tmp = $*TMPDIR ~ '/sample.blocks';
spurt $tmp, $fixture;

my $proc = run 'raku', 'parse-blocks.raku', '--in=' ~ $tmp, '--out=-', :out, :err;
my $out = $proc.out.slurp-rest;
my $err = $proc.err.slurp-rest;
is $proc.exitcode, 0, 'parse-blocks exited cleanly';

my @data = from-json $out;
ok @data.elems >= 2, 'parsed at least two lines';

my %pb = @data.grep(*.<is_double_play> == False).head // {};
my %dp = @data.grep(*.<is_double_play> == True).head // {};

ok %pb<multiplier>:exists, 'pb row has multiplier key';
ok %dp<is_double_play> === True, 'dp row marked as Double Play';
ok %pb<draw_date> ~~ / ^ \d ** 4 '-' \d ** 2 '-' \d ** 2 $ /, 'ISO date OK';

diag $err if $err.chars;

done-testing;
