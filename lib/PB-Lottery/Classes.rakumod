unit module PB-Lottery::Classes;

# need some helper subs to parse input strings...
# see old-code* for pieces
sub set-draw-numsh(Str $s) {}
sub set-draw-numsh2(Str $s) {}
sub set-ticket-numsh(Str $s) {}
sub set-date(Str $s) {}

class PB-Draw is export {
    has Str  $.nums  is required;
    has Str  $.nums2 is required;

    has Hash %.numsh;
    has Hash %.nums2h;
    has Date $.date;

    submethod TWEAK {
        %!numsh = set-draw-numsh $!nums; 
        %!nums2h = set-draw-numsh2 $!nums2; 
        $!date = set-date $!nums;
    }
}

class PB-Ticket is export {
    has Str  $.nums is required;

    has Hash %.numsh;
    has Date $.date;
    has Bool $.is-qp;

    submethod TWEAK {
        %!numsh = set-ticket-numsh $!nums; 
        $!date = set-date $!nums;
    }
}


