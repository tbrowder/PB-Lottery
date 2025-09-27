unit module PB-Lottery::Classes;

use Text::Utils :strip-comment;

use PB-Lottery::Indy;

=begin comment
#========================================================
#========================================================
#
# need some helper subs to parse input strings...
# see old-code* for pieces
#
# all valid entry lines (space-separated tokens):
#
# the first seven entries are required for ALL entry types
# nn nn nn nn nn nn yyyy-mm-dd
#
# additional tokens:
#
# draw number 1 of 2
# nx # where n must be one of: 2..5, 10
# draw number 2 of 2
# dp # mandatory, indicates it's the double play draw
#
# ticket
# none or up to three of: pp dp qp
# where:
#   pp = power play
#   dp = double play
#   qp = quick pick (if the numbers were so produced)
#
#       if $!entry ~~ /^
#           \h* (\d+) # 0 - first number
#           \h+ (\d+) # 1 - second number
#           \h+ (\d+) # 2 - third number
#           \h+ (\d+) # 3 - fourth number
#           \h+ (\d+) # 4 - fifth number
#           \h+ (\d+) # 5 - sixth number
#
#           # the date is required
#           # 6 - seventh word
#           [\h+ (\d\d\d\d '-' \d\d '-' \d\d)]
            # one to three more two-char entries
            # depending on the base type: draw or ticket
#
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
#            [\h+ (\w\w)] # required (lottery type): 'pb' or 'dp'
            #
            # 8 - ninth word
#            [\h+ (\w\w)]? # dp, pb, or qp
            # 9
#            [\h+ (\w\w)]? # dp, dp, or qp
#
=end comment
#========================================================
#========================================================

class PB-Draw is export {
    has Str $.numbers-str  is required;
    has Str $.numbers-str2 is required;

    has Hash %.numbers-hash;
    has Hash %.numbers-hash2;
    has Date $.date;
    has Str  $.type;

    submethod TWEAK {
        %!numbers-hash  = create-numhash $!numbers-str;
        %!numbers-hash2 = create-numhash $!numbers-str2;
        $!date = Date.new: %!numbers-hash<DATE>;
        $!type = %!numbers-hash<TYPE>;
    }
} # end of class PB-Draw

class PB-Ticket is export {
    has Str  $.numbers-str is required;

    has Hash %.numbers-hash;
    has Date $.date;
    has Str  $.type;

    has Bool $.is-qp;

    submethod TWEAK {
        %!numbers-hash = create-numhash $!numbers-str;
        $!date = Date.new: %!numbers-hash<DATE>;
        $!type = %!numbers-hash<TYPE>;
    }
} # end of class PB-ticket
