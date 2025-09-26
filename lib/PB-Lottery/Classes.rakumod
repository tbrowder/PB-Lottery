unit module PB-Lottery::Classes;

use Text::Utils :strip-comment;

use PB-Lottery::Indy;

=begin comment
# need some helper subs to parse input strings...
# see old-code* for pieces

# all valid entry lines (space-separated tokens):

# the first seven entries are required for ALL entry types
nn nn nn nn nn nn yyyy-mm-dd

# additional tokens:

# draw number 1 of 2 
nx # where n must be one of: 2..5, 10
# draw number 2 of 2 
dp # mandatory, indicates it's the double play draw

# ticket 
# none or up to three of: pp dp qp
# where:
#   pp = power play
#   dp = double play
#   qp = quick pick (if the numbers were so produced)

        if $!entry ~~ /^
            \h* (\d+) # 0 - first number
            \h+ (\d+) # 1 - second number
            \h+ (\d+) # 2 - third number
            \h+ (\d+) # 3 - fourth number
            \h+ (\d+) # 4 - fifth number
            \h+ (\d+) # 5 - sixth number

            # the date is required
            # 6 - seventh word
            [\h+ (\d\d\d\d '-' \d\d '-' \d\d)]

            # one to three more two-char entries
            # depending on the base type: draw or ticket

            # 7 - eighth word
            # This mandatory entry is a bit confusing because
            # Florida's Power Ball lottery has a double play
            # option which requires a draw object to have two
            # lines and each could have a separate type.
            # I just decided the second draw entry must use the 'dp'
            # code as the only valid one.
            # On a ticket entry the seventh code must be 'dp' or 'pb'.
            # Then any additional entries should not be a duplicate
            # of the seventh entry.
            [\h+ (\w\w)] # required (lottery type): 'pb' or 'dp'
            
            # 
            # 8 - ninth word
            [\h+ (\w\w)]? # dp, pb, or qp
            # 9
            [\h+ (\w\w)]? # dp, dp, or qp

=end comment

# Recognized Powerball "type" words
# (prefer lower-cased)
my %valid-types = set <
    2x 3x 4x 5x 10x
    2X 3X 4X 5X 10X
    pb Pb pB PB 
    dp Dp dP DP
>;

sub split-powerball-line(
    Str $s, #= the raw line with 8..11 tokens
    :$debug,
    --> List # returns three or four strings (
) {
    my $s0 = strip-comment $s;
    my @w = $s0.words;
    my $nw = @w.elems;
    unless $nw >= 8 {
        my $msg = "String '$s0' has less than eight words";
        throw-err $msg;
    }

    my @w1 = []; # first six should be numbers
    my @w2 = []; # seventh should be the date
    my @w3 = []; # eighth should be type
    my @w4 = []; # any extra type info

    my %types-used; # one to three: Nx pb dp
    for @w.kv -> $i, $v is copy {
        with $i {
            when * < 6 {
                # a number from 1..69
                $v = trim-leading-zeros $v;
                die unless { 0 < $v <= 69 }
                @w1.push: $v;
            }
            when * == 6 {
                # a number from 1..26
                $v = trim-leading-zeros $v;
                die unless { 0 < $v <= 26 }
                @w1.push: $v;
            }
            when * == 7 {
                # the date: yyyy-mm-dd
                die unless { 
                    $v ~~ / \d\d\d\d '-' \d\d '-' \d\d /;
                }
                @w2.push: $v;
            }
            when * == 8 {
                $v .= lc;
                # must be the type if only 8 words
                if $nw == 8 {
                    unless %valid-types{$v}:exists {
                        my $msg = "Type '$v' is not recognized.";
                        throw-err $msg; 
                    }
                    @w3.push: $v;
                }
                else {
                    if %valid-types{$v}:exists {
                        @w3.push: $v;
                    }
                    else {
                        @w4.push: $v;
                    }
                }
            }
            default {
                $v .= lc;
                if %valid-types{$v}:exists {
                    @w3.push: $v;
                }
                else {
                    @w4.push: $v;
                }
            }
        }
    }

    my $s1 = @w1.join(' ').lc;
    my $s2 = @w2.join(' ').lc;
    my $s3 = @w3.join(' ').lc;
    my $s4 = @w4.join(' ').lc;
    $s1, $s2, $s3, $s4; # $s4 may be empty
} # end of sub split-powerball-line

sub set-draw-numsh(
    Str $s
) {
    my @parts = split-powerball-line $s;
    my %h;
}
sub set-draw-numsh2(
    Str $s
) {
    my %h;
}
sub set-ticket-numsh(
    Str $s
) {
    my %h;
}
sub set-date(
    Str $s
) {
    my Date $date;
}

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


