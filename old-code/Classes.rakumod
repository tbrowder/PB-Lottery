unit module PB-Lottery::Classes;

use Text::Utils :strip-comment;

use PB-Lottery::Indy;

my $F = $?FILE.IO.basename;

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
# none or up to three of: pp dp pb qp
# where:
#   pp = power play
#   dp = double play
#   pb = power ball
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

=finish

class PB-nums   {...}
class PB-Draw   {...}
class PB-Ticket {...}

class PB-nums {
    has Str  $.num-str is required;  # "00 00 00 00 00 00";
    has      %.num-hash of UInt;     # keys: 'a..f

    submethod TWEAK {
        my @w = $!num-str.words;
        my @a = 'a'..'f';
        for @w.kv -> $i, $v is copy {
            my $k  = @a[$i];
            my $nc = $v.chars;
            die "FATAL: str $v has other 1 or 2 chars" unless {0 < $nc < 3};
            if $v ~~ / 0 (\d) / {
                %!num-hash{$k} = +$0.UInt;
            }
            else {
                %!num-hash{$k} = $v.UInt;
            }

            # other requirements
            my $res = %!num-hash{$k};
            if $i < 5 {
                # range is 1..69
                die "FATAL: int $res is out of range 1..69" unless {0 < $res < 70}
            }
            else {
                # range is 1..26
                die "FATAL: int $res is out of range 1..26" unless {0 < $res < 27}
            }
        }
        # the first 5 numbers must be unique
  #     die "FATAL: The first 5 numbers must be unique" unless {
	my @arr = [%!num-hash.keys<a>..%!num-hash<e>];

    }
}

class PB-Draw {
    has Str $.numbers-str  is required;
    has Str $.numbers-str2 is required;

    has      %.numbers-hash;
    has      %.numbers-hash2;
    has Date $.date;
    has Str  $.type;

    has $debug = 0;

    submethod TWEAK {
        my $s  = $!numbers-str;
        my $s2 = $!numbers-str2;

        %!numbers-hash  = create-numhash $s,  :$debug;
        %!numbers-hash2 = create-numhash $s2, :$debug;
        $!date = Date.new: %!numbers-hash<DATE>;
        $!type = %!numbers-hash<TYPE>;
    }
} # end of class PB-Draw

class PB-Ticket {
    has Str  $.numbers-str is required;

    has      %.numbers-hash;
    has Date $.date;
    has Str  $.type;

    has Bool $.is-qp;

    submethod TWEAK {
        unless $!numbers-str ~~ /\S/ {
            my $msg = "Cannot create a PB-Ticket object with an empty input string";
            throw-err $msg;
        }
        %!numbers-hash = create-numhash $!numbers-str, :is-ticket(True);
        $!date = Date.new: %!numbers-hash<DATE>;
        $!type = %!numbers-hash<TYPE>;
    }
} # end of class PB-ticket
