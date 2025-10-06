unit module PB-Lottery::Subs;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

use PB-Lottery::Vars;

# All items here MUST be dependent
# only upon Raku core or external
# distributions.

# Recognized Powerball "type" words
# (prefer lower-cased)

# in order to accomodate other lottery
# types, we require a ticket to
# have at least one of:
#   pp dp pb
# all of which are exclusive to
# the Power Ball lottery in Florida
our %valid-ticket-types is export = set <
    dp Dp dP DP
    pp Pp pP PP
    pb Pb pB PB

>;
#   qp Qp qP QP

our %valid-draw-types is export = set <
    2x 3x 4x 5x 10x
    2X 3X 4X 5X 10X

    dp Dp dP DP
>;

sub trim-leading-zeros(
    $s is copy,
    :$debug,
) is export {
    $s .= trim;
    if $s ~~ /^0 \d/ {
        $s ~~ s/^0//;
    }

    $s;
} # end sub trim-leading-zeros

sub throw-err(
    $msg,
    :$debug,
) is export {
    die qq:to/HERE/;
    FATAL: $msg
    HERE
} # end sub throw-err

sub get-dollars(
    Str $m is copy,
    :$debug,
    --> UInt
) is export {
    # reduce input money amounts in integer values
    # example inputs allowed
    # $1.4b
    # 1,400m
    # 1,400,000t
    # 1,400,000,000.00

    # remove any leading currency chars
    $m ~~ s/^ '$'//;
    # remove any commas
    $m ~~ s:g/','//;

    my $mult = 1.0;

    # consider any suffixes
    with $m.comb.tail.lc {
        when * eq 'b' {
            $mult = 1_000_000_000;
            $m ~~ s/:i b $//;
        }
        when * eq 'm' {
            $mult = 1_000_000;
            $m ~~ s/:i m $//;
        }
        when * eq 't' {
            $mult = 1_000;
            $m ~~ s/:i t $//;
        }
    }

    # convert to a Numeric
    my $num = $m.Numeric;

    # apply the multiplier
    $num *= $mult;

    $num .= UInt;

} # end of sub get-dollars

sub str2intlist(
    # from ChatGPT
    Str $s,
    :$no-zeros       = True,
    :$no-negatives   = True,
    :$only-positives = True,
    :$debug,
   --> List
) is export {

    my @words = $s.words;
    # validate tokens
    for @words -> $tok {
        unless $tok ~~ /^ '-'? \d+ $/ {
            die "Non-numeric token found: |$tok|";
        }
    }

    # normalize to Ints
    my @ints = @words.map({ .Int });
    if $only-positives {
        @ints .= grep({ $_ != 0}) if $no-zeros;
    }
    else {
        @ints .= grep({ $_ != 0}) if $no-zeros;
        @ints .= grep({ $_ >= 0}) if $no-negatives;
    }

    # Ints unique and sorted
    @ints.unique.sort({ $^a <=> $^b }).List;
} # end of sub str2intlist

sub Lstr2info-hash(
    Str $s is copy,
    --> Hash
) is export {
    # use the first six numbers in a string to provide a
    # Power Ball info hash:
    #   "nn nn nn nn nn nn yyyy-mm-dd pb dp qp
    # use the rest of the line, if any, to provide additional data
    my %h;

    $s = strip-comment $s;
    my $s2 = ""; # for any additional data
    # check with a hash
    if $s ~~ /^
        \h* \d\d      # ~$0
        \h+ \d\d      # ~$1
        \h+ \d\d      # ~$2
        \h+ \d\d      # ~$3
        \h+ \d\d      # ~$4
        \h+ \d\d \h*  # ~$5

        # that may be the end OR more space-separated chars
        # which we will treat separately
        [\h+ .*]?     # ~$6

        $/ {

        if $6.defined {
            $s2 = ~$6;
        }
    }
    else {
        my $msg = "Unrecognized line format: |$s|";
        throw-err $msg;
    }

    my @nums = $s.words[0..^6];
    # take care of the numbers: sort the first 5 and ensure
    #   they are in the range 1..69
    # the sixth is the power ball in the range 1..26

    # Now take care of the remaining data, if any. Put them
    # in the same hash:
    if $s2 {
        my @w = $s2.words;
        for @w.kv -> $i, $w {
            if $i == 0 {
                %h<date> = $w;
                next;
            }
            if $w ~~ /pb/ { %h<pb> = 1; next; }
            if $w ~~ /dp/ { %h<dp> = 1; next; }
            if $w ~~ /qp/ { %h<qp> = 1; next; }
        }
    }

    %h;
} # end sub Lstr2info-hash
