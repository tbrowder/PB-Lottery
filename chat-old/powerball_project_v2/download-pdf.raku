#!/usr/bin/env raku
use v6;
use LibCurl::Easy;

sub MAIN(:$url='https://files.floridalottery.com/exptkt/pb.pdf', :$out='pb.pdf', :$timeout=60, :$connect-timeout=30) {
    my $curl = LibCurl::Easy.new(URL => $url, download => $out);
    $curl.followlocation(True);
    $curl.failonerror(True);
    $curl.timeout($timeout);
    $curl.connecttimeout($connect-timeout);
    $curl.perform;
    say "Wrote {$out}";
}
