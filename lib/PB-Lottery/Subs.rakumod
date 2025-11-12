unit module PB-Lottery::Subs;

my $F = $?FILE.IO.basename;

use Test;

use LibCurl::Easy;
use Text::Utils :strip-comment, :str2intlist;

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

class SPair {
    has Str $.L is required;
    has Str $.R is required;
}

sub get-file-mod-time(
    $file
    --> Date 
) is export {
    # DEBUG: File '/var/local/powerball/pb.pdf' access time: 
    # '-rw-r--r-- 1 root root 686506 Nov 11 07:30 /var/local/powerball/pb.pdf
    #   $t1 = run 'ls', '-l', $f1, :out, :err;
    #   $a1 = $t1.out.slurp(:close);
    #   say "DEBUG: File '$f1' access time: '$a1'" if $debug;
    #   die "Fatal file '$f1' access error" if $t1.exitcode != 0;
    my $proc = run 'ls', '-l', $file, :out, :err;

    # '-rw-r--r-- 1 root root 686506 Nov       11 07:30 /var/local/powerball/pb.pdf
    #                 686506   Nov       11       07:30 /var/local/powerball/pb.pdf
    if $mtim ~~ / \h+ \d+ \h+ (\w+) \h+ (\d+) \h+ ($proc.out.slurp(:close);

} # end of sub get-file-mod-time

) 
sub get-pdir-from-envar(
    --> Str
) is export {
    my $pdir = %*ENV{$pdir-env-var} // die qq:to/HERE/;
    FATAL: The required environment variable

              $pdir-env-var

           is not defined.  See the README for details.
           Exiting...
    HERE
    $pdir;
} # end of sub get-pdir-envar

sub show-string-matches(
    Str :$Lstr1!,
    Str :$Lstr2!,
    Str :$Rstr!,
    --> List # of Str # the two pairs of show strings
) is export {
    # show the draw/ticket in two columns
    # nn nn nn nn nn nn | nn nn nn nn nn nn # Lstr1 Rstr
    #                        --    --
    # nn nn nn nn nn nn | nn nn nn nn nn nn # Lstr2 Rstr
    #                     --    --
    my $l1 = SPair.new: :L($Lstr1), :R($Rstr);
    my $l2 = SPair.new: :L($Lstr2), :R($Rstr);
    my $nl1 = PB-Lottery::Numbers.new: :numbers-str($Lstr1);
    isa-ok $nl1, OP-Lottery::Numbers;
}

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

# sub get-pb-hash:
# our @power-ball-prizes is export = [
sub get-pb-hash(
    --> Hash
) is export {
    =begin comment
    my %h;
    for @power-ball-prizes.kv -> $i, $line is copy {
        $line = strip-comment $line;
        my @w = $line.words;
        my $code  = @w.head; # the key
        my $prize = @w.tail; # the value
        %h{$code} = $prize;
    }
    %h;
    =end comment
    %power-ball-prizes; #.kv -> $i, $line is copy {
} # end sub get-pb-hash

# sub get-dp-hash:
# our @double-play-prizes is export = [
sub get-dp-hash(
    --> Hash
) is export {
    =begin comment
    my %h;
    for @double-play-prizes.kv -> $i, $line is copy {
        $line = strip-comment $line;
        my @w = $line.words;
        my $code  = @w.head; # the key
        my $prize = @w.tail; # the value
        %h{$code} = $prize;
    }
    %h;
    =end comment
    %double-play-prizes; # .kv -> $i, $line is copy {
} # end sub get-dp-hash

=begin comment
# sub get-pp-hash:
# our @power-play-prizes is export = [
sub get-pp-hash(
    --> Hash
) is export {
    =begin comment
    my %h;
    for @power-play-prizes.kv -> $i, $line is copy {
        $line = strip-comment $line;
        my @w = $line.words;
        my $code  = @w.head; # the key
        my $prize = @w.tail; # the value
        %h{$code} = $prize;
    }
    %h;
    =end comment
    %power-play-prizes; #.kv -> $i, $line is copy {
} # end sub get-pp-hash
=end comment

# my $pb-code = get-pb-code :$n5set, :$pbset;
# my $pp-code = get-pp-code :$n5set, :$pbset;
# my $dp-code = get-dp-code :$n5set, :$pbset;
sub get-pb-code(
    :$n5set,
    :$pbset,
    --> Str # the code
) is export {
    my @n = $n5set.keys;
    my @p = $pbset.keys;

    my $c = " ";
} # end of sub get-pb-code

sub get-pp-code(
    :$n5set,
    :$pbset,
    --> Str # the code
) is export {
    my @n = $n5set.keys;
    my @p = $pbset.keys;

    my $c = " ";
} # end of sub get-pp-code

=begin comment
"5+pb jackpot",
"5    1_000_000",
"4+pb 50_000",
"4    100",
"3+pb 100",
"3    7",
"2+pb 7",
"1+pb 4",
"pb   4",
=end comment

sub get-prize-code(
    :$n5set,
    :$pbset,
    --> Str # the code
) is export {
    my @n = $n5set.keys;
    my @p = $pbset.keys;
    my $code;
    my $nn = @n.elems;
    my $np = @p.elems;
    if $nn and $np {
        $code = "{$nn}+pb";
    }
    elsif $nn {
        $code = "{$nn}";
        if $code == 1 {
            # set to zero
            $code = "0";
        }
    }
    elsif $np {
        $code = "pb";
    }

    $code;
} # end of sub get-prize-code

sub exp-prize(
    :$nm! where * ~~ /^ 0|1|2|3|4|5 $/, # number matches
    :$np! where * ~~ /^ 0|1 $/,         # power ball match?
    :$dp,
    :$pp,
    --> Numeric
) is export {
    my $prize = 0;
}

# WHY THIS:
sub intlist2str(
    @intlist, #= a list of words representing ints
    :$debug,
    --> Str
) is export {
    my @list = [];
    # ensure the incoming list is sorted numerically
    my $tmpstr = @intlist.join(' ');
    @list = str2intlist $tmpstr; # .sort({$^a <=> $^b});
    my Str $s = "";
    for @list.kv -> $i, $int is copy {
        $s ~= " " if $i;
        if $int.chars == 1 {
            $int = "0$int";
            $s ~= $int.Str;
        }
        else {
            $s ~= $int.Str;
        }
    }
    $s.Str;
} # end of sub intlist2str

sub scrape(
) is export {

=begin comment
    # first page
    https://files.floridalottery.com/exptkt/pb.pdf?
      _gl=1*15gprlx*_ga*Mzc3NzE5MDk0LjE3NTgwMzg2ODA.*_ga_3E9WN4YVMF*czE3NjA1MzAzNDckbzUkZzEkdDE3NjA1MzA2NTMkajI2JGwwJGgw
=end comment

    my $addr = "https://floridalottery.com/games/draw-games/powerball";
    my $curl = LibCurl::Easy.new(:verbose, :followlocation);
    $curl.setopt(
        URL => $addr,
    );
    $curl.perform;
    say $curl.success;
    say $curl.content;
}

=begin comment
sub power-play-factor(
     $pp-code,
     :$Nx!,
     :$debug,
     --> Numeric
) is export {
    my $mult = 1;
    unless %power-play-codes{$pp-code}:exists {
        die "FATAL: Unknown Power Play code '$pp-code'";
    }

    with $pp-code {
    }

    $mult;
} # end sub power-play-factor
=end comment
