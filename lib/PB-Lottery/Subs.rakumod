unit module PB-Lottery::Subs;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;

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

    =begin comment
    if $s.chars > 1 {
        # a '09' is sneaking through
        if $s.comb.head == 0 {
            die "FATAL: First char is a zero";
        }
    }
    =end comment

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

sub split-powerball-line(
    # caller is sub create-numhash
    Str $s, #= the raw line with 8..11 tokens
    :$is-ticket = False,
    :$debug,
    --> List # returns four strings (
) is export {
    my ($min-words, %valid-types, $typ);
    if $is-ticket {
        $typ = "ticket";
        $min-words = 8;
        %valid-types = %valid-ticket-types;
    }
    else {
        $min-words = 8;
        $typ = "draw";
        %valid-types = %valid-draw-types;
    }

    my $s0 = strip-comment $s;
    my @w = $s0.words;
    my $nw = @w.elems;
    if $nw == 0 {
        note qq:to/HERE/;
        DEBUG: EMPTY input line!
               How did it get here in sub split-powerball-line of type $typ?
        HERE
        return [];
    }
    unless $nw >= $min-words {
        my $msg = "String '$s0' has less than $min-words words";
        throw-err $msg;
    }

    my @w1 = []; # first six should be numbers
    my @w2 = []; # seventh should be the date string "yyyy-mm-dd"
    my @w3 = []; # eighth should be type
    my @w4 = []; # any extra type or jackpot info

#   my %types-used;
    for @w.kv -> $i, $v is copy {
        $v .= trim;
        my $n = $i + 1;
        my $msg = "n=$n";
        with $n {

            when * < 6 {
                # a number from 1..69
                $v = trim-leading-zeros $v;
                $v .= Int;
                die $msg unless { 0 < $v <= 69 }
                @w1.push: $v;
            }
            when * == 6 {
                # a number from 1..26
                $v = trim-leading-zeros $v;
                $v .= Int;
                die $msg unless { 0 < $v <= 26 }
                @w1.push: $v;
            }
            when * == 7 {
                # the date: yyyy-mm-dd
                die $msg unless {
                    $v ~~ / \d\d\d\d '-' \d\d '-' \d\d /;
                }
                @w2.push: $v;
            }
            when * == 8 {
                $v .= lc;
                # must be the type if only 8 words
                if $nw == 8 {
                    unless %valid-types{$v}:exists {
                        my $msg = "Type '$v' is not recognized for a $typ.";
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

    # don't forget to separate the power ball before doing
    # the numerical sort of the numbers...
    # do it later
    my $s1 = @w1.join(' ').lc;
    my $s2 = @w2.head; # a valid Date string
    my $s3 = @w3.join(' ').lc;
    my $s4;
    if @w4.elems {
        $s4 = @w4.join(' ').lc;
    }
    else {
        $s4 = "";
    }

    if 0 and $debug {
        say "DEBUG in file: '$F'";
        print qq:to/HERE/;
        \$s1: |$s1|
        \$s2: |$s2|
        \$s3: |$s3|
        \$s4: |$s4|
        HERE

        say "DEBUG: Early exit...";
        exit(1);
    }

    $s1, $s2, $s3, $s4; # $s4 may be empty


} # end of sub split-powerball-line

sub create-numhash(
    # this sub is called in TWEAK for draw and ticket objects
    Str $s,
    :$is-ticket = False,
    :$debug,
    --> Hash
) is export {
    my ($min-words, $typ);
    if $is-ticket {
        $typ = "ticket";
        $min-words = 8;
    }
    else {
        $min-words = 8;
        $typ = "draw";
    }

    unless $s ~~ /\S/ {
        my $msg = "Cannot create a numhash from an empty string for a $typ type.";
        throw-err $msg;
    }
    my ($s1, $s2, $s3, $s4) = split-powerball-line $s, :$is-ticket, :$debug;

    # $s1 contains the first 6 numbers
    # $s2 contains the date string
    # $s3 contains the Lottery type code
    # $s4 contains up to two other codes or the jackpot info
    #     or it may be blank

    my @nums = [];
    for $s1.words -> $v is copy {
        $v.trim;
        $v = trim-leading-zeros $v;
        $v .= Int;
        @nums.push: $v;
    }
    my $nw = @nums.elems;
    unless $nw == 6 {
        my $msg = "String '$s1' contains $nw parts for type $typ, expected 6";
        throw-err $msg;
    }

    my %h;
    my $PB = @nums.pop; # the tail is the power ball
    @nums .= sort({ $^a <=> $^b });

    =begin comment
    # from the test file: t/data/good/draws.txt
    # good draw formats:
    09 12 22 41 61 25 2025-08-27 4x # <== power play multiplier
    09 12 22 41 61 25 2025-08-27 4x jackpot # <== jackpot string
    =end comment

    # now rejoin them
    @nums.push: $PB;

    for ['a'..'f'].kv -> $i, $alpha {
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

        # if the type is Nx, then any extra piece is expected
        #   to be a jackpot
        if %h<TYPE> ~~ /:i x/ {
            my $s = @w.head;
            %h<JACKPOT> = get-dollars $s;
        }
        else {
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
    }

    if 0 and $debug {
        # the incoming list of strings seemed good.
        # what does the hash look like at this point?
        say "DEBUG in file '$F'";
        say "  contents of final hash %h:";
        my @keys = %h.keys.sort;
        for @keys -> $k {
            my $v = %h{$k};
            say "  key: $k";
            say "    value: |$v|"
        }
        say "DEBUG: early exit...";
        exit(1);
    }

    %h
} # end of sub create-numhash

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
