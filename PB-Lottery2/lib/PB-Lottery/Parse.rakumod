unit module PB::Lottery::Parse;

# Convert the Florida Powerball PDF text into structured records.

use PB::Lottery::Format;

sub parse-pdf(Str $pdf-path --> Array) is export {
    # TODO: Invoke 'pdftotext', scan lines, parse with Format::parse-line
    # Return an Array of record Hashes
    ...
}
