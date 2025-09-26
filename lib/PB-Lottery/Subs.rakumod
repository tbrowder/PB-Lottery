unit module PB-Lottery::Subs;

use Text::Utils :strip-comment;

sub throw-err(
    $msg
) is export {
    die qq:to/HERE/;
    FATAL: $msg
    HERE
}

# in Subs:
sub trim-zeros(
    $s is copy 
    --> UInt
) is export {
    if $s ~~ /^0/ {
        $s ~~ s/^0//;
    }
    $s;
} # end sub trim-zeros

# in Subs:
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
