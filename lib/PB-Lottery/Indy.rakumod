unit module PB-Lottery::Indy;

# All items here MUST be dependent
# only on Rsku core or external
# distributions.

sub trim-leading-zeros(
    $s is copy 
    #--> UInt
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
