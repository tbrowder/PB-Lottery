#!/usr/bin/env raku

use LibCurl::Easy;

# the download example modified to use the real name
my $ofil = "pb.pdf";
my $addr = "https://files.floridalottery.com/exptkt/pb.pdf";
my $curl = LibCurl::Easy.new(
    URL => $addr,
    download => $ofil);
$curl.perform;
say "See output file: '$ofil'";
