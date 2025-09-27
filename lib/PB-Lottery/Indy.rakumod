unit module PB-Lottery::Indy;

use Text::Utils :strip-comment;

# All items here MUST be dependent
# only on Rsku core or external
# distributions.

# Recognized Powerball "type" words
# (prefer lower-cased)
our %valid-types is export = set <
    2x 3x 4x 5x 10x
    2X 3X 4X 5X 10X
    pb Pb pB PB
    dp Dp dP DP
>;

sub trim-leading-zeros(
    $s is copy
) is export {
    if $s ~~ /^0 \d/ {
        $s ~~ s/^0//;
    }
    $s;
} # end sub trim-leading-zeros

sub throw-err(
    $msg
) is export {
    die qq:to/HERE/;
    FATAL: $msg
    HERE
} # end sub throw-err

sub split-powerball-line(
    Str $s, #= the raw line with 8..11 tokens
    :$debug,
    --> List # returns three or four strings (
) is export {
    my $s0 = strip-comment $s;
    my @w = $s0.words;
    my $nw = @w.elems;
    unless $nw >= 8 {
        my $msg = "String '$s0' has less than eight words";
        throw-err $msg;
    }

    my @w1 = []; # first six should be numbers
    my @w2 = []; # seventh should be the date string "yyyy-mm-dd"
    my @w3 = []; # eighth should be type
    my @w4 = []; # any extra type info

    my %types-used; # one to three: Nx pb dp
    for @w.kv -> $i, $v is copy {
        my $n = $i + 1;
        with $n {
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
        } # end with block
    } # end for loop

    my $s1 = @w1.join(' ').lc;
    my $s2 = @w2.head; # a valid Date string
    my $s3 = @w3.join(' ').lc;
    my $s4 = @w4.join(' ').lc;
    $s1, $s2, $s3, $s4; # $s4 may be empty

} # end of sub split-powerball-line

sub create-numhash(
    Str $s,
    --> Hash
) is export {
    my ($s1, $s2, $s3, $s4) = split-powerball-line $s;

    # $s1 contains the first 6 numbers
    # $s2 contains the date string
    # $s3 contains the Lottery type code
    # $s4 contains up to two other codes

    my @nums = $s1.words;
    my $nw = @nums.elems;
    unless $nw == 6 {
        my $msg = "String '$s1' contains $nw parts, expected 6";
        throw-err $msg;
    }

    my %h;
    @nums .= sort({ $^a cmp $^b });
    for ('a'..'f').kv -> $i, $alpha {
        my $num = @nums[$i];
        # dont't stringify yet
        %h{$alpha} = $num;
    }
    # the date
    %h<DATE> = $s2;
    # the type code is $s3
    %h<TYPE> = $s3;
    if $s4 {
        # add extra pieces
        my @w = $s4.words;
        my $nw = @w.elems;
        unless (1 <= $nw <= 3) {
            my $msg = "String '$s4' contains $nw parts, expected 1 to 3";
            throw-err $msg;
        }
        for @w.kv -> $i, $v {
            my $alpha;
            with $i {
                when * == 0 { $alpha = 'g' }
                when * == 1 { $alpha = 'h' }
                when * == 2 { $alpha = 'i' }
            }
            %h{$alpha} = $v;
        }
    }

    %h
} # end of sub create-numhash
