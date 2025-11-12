unit module PB-Lottery::Append;

use PB-Lottery::Draw;
use PB-Lottery::Draw;

=begin comment

We want to ensure some files are only appended to
but only in proper date order. In order to do
that, each file needs to be read first, determine validity,
then opened to append, then updated as necessary.
Each file type should have its own class type.

At the moment, the only two files of concern are:

    draws.txt
    pb.txt

=end comment

sub handle-draws-txt-file(
) is export {
} # end of sub handle-draws-txt-file

sub handle-pb-txt-file(
) is export {
} # end of sub handle-pb-txt-file


