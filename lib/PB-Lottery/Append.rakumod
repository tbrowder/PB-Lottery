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

They are produced from the Florida Lotter website's pb.pdf file
which is in one or both of two locations.

The manual method expects all files to be in the user's private
directory. Both files are appended to if they already exist.
If not they are created with the latest data for the creation
date.

The semi-automatic method respects the user's current
files also but may create new files in the "/var/local/powerball"
directory with an earlier starting data point.
=end comment

sub handle-draws-txt-file(
    $pdf-file,
    :$draws-txt!,
    :$debug,
) is export {
    
} # end of sub handle-draws-txt-file

sub handle-pb-txt-file(
    $pdf-file,
    :$pb-txt!,
    :$debug,
) is export {
} # end of sub handle-pb-txt-file


