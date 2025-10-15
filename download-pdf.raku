#!/usr/bin/env raku

use LibCurl::Easy;

=begin comment
    # first page
    https://files.floridalottery.com/exptkt/pb.pdf?
      _gl=1*15gprlx*_ga*Mzc3NzE5MDk0LjE3NTgwMzg2ODA.*_ga_3E9WN4YVMF*czE3NjA1MzAzNDckbzUkZzEkdDE3NjA1MzA2NTMkajI2JGwwJGgw
=end comment

=begin comment
#my $addr = "https://floridalottery.com/games/draw-games/powerball";
my $addr = "https://files.floridalottery.com/exptkt/pb.pdf";
my $curl = LibCurl::Easy.new(:verbose, :followlocation);
$curl.setopt(
    URL => $addr,
);
$curl.perform;
say $curl.success;
say $curl.content;
=end comment

# the download example
my $ofil = "full-draw-history.pdf";
my $addr = "https://files.floridalottery.com/exptkt/pb.pdf";
my $curl = LibCurl::Easy.new(
    URL => $addr, 
    download => $ofil);
$curl.perform;
say "See output file: '$ofil'";

