use v6;
use Test;
use JSON::Fast;

my $run-int = %*ENV<RUN_INTEGRATION>:exists;
plan $run-int ?? 4 !! 1;

unless $run-int {
    skip 'Set RUN_INTEGRATION=1 to enable integration test';
    done-testing;
    exit;
}

# Check pdftotext is available
my $which = run 'bash', '-lc', 'command -v pdftotext', :out, :err;
if $which.exitcode != 0 {
    skip-rest 'pdftotext not available; install poppler-utils';
    done-testing;
    exit;
}

my $p = run 'raku', 'emit-blocks.raku', '--last=2', '--emit=json', :out, :err;
is $p.exitcode, 0, 'emit-blocks ran';

my $json = $p.out.slurp-rest;
my @rows = from-json $json;
ok @rows.elems >= 2, 'got some rows';

# Ensure normalized keys
ok @rows[0]<draw_date>:exists, 'draw_date present';
ok @rows[0]<numbers>:exists, 'numbers present';

note $p.err.slurp-rest if $p.err.slurp-rest.chars;

done-testing;
