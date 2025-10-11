unit class PB-Lottery::Event;

use Text::Utils :strip-comment, :str2intlist;

use PB-Lottery::Draw;
use PB-Lottery::Ticket;

has $.draw of PB-Lottery::Draw      is required;
has @.tickets of PB-Lottery::Ticket is required;

has $.date;

has @.valid-tickets of PB-Lottery::Ticket is built;

submethod TWEAK {
    $!date = $!draw.date;
    # eliminate tickets paid or out of date
    for @!tickets -> $t {
        die "FATAl: \$t is not a valid Ticket" unless $t ~~ PB-Lottery::Ticket;
        my $valid-date = $t.date;
        my $paid = $t.paid;
        next if $t.paid;
        next if $valid-date < $!date;
        @!valid-tickets.push: $t;
    }
}

method show-matches(
    :$all, 
    :$debug,

) {
    say "DEBUG: in method show-matches" if 1 or $debug;
    my $d = $!draw;
    die "FATAL: not a Draw" unless $d ~~ PB-Lottery::Draw;

    # $e.draw.print1; print " | "; $e.draw.print2; say();

    # sort the tickets by winnings if more than one
    if @!valid-tickets.elems > 1 {
        say "NOTE: Multiple tickets are not yet sorted by winnings...";
        say "      File an issue if that is desired.";
    }

    for @!valid-tickets -> $t {
        die "FATAL: not a Ticket" unless $t ~~ PB-Lottery::Ticket;
        show-ticket-matches :draw($!draw), :ticket($t);

#       $d.print1; print " | "; $t.print1; say();
#       $d.print2; print " | "; $t.print2; say();
    }
} # end method show-matches

sub show-ticket-matches(
    :$draw!,
    :$ticket!,
    :$debug,
) {
    say "DEBUG: in sub show-ticket-matches" if 1 or $debug;

    # show the draw/ticket in two columns
# 1 #   main draw
    #   nums5        pb | nums5          pb
    #   (MLn)     (MLp) | (MRn)       (MRp)
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    # --             -- |       --       --
# sub show-str-match: $d.numbers-str, $t.numbers-str => output: the two lines above

# 2 #   double play
    #   nums5        pb | nums5          pb
    #   (DLn)     (DLp) | (DRn)       (DRp)
    # nn nn nn nn nn nn | nn nn nn nn nn nn
    #    -- --          | --    --
# sub show-str-match: $d.numbers-str2, $t.numbers-str => output: the two lines above

    # where the "--" (or other suitable double char) indicates
    #   a match of that ticket's numbers with those of the
    #   draw's power ball's  or double play's numbers

    my $d = $draw;
    die "FATAL: \$d is not a valid Draw" unless $d ~~ PB-Lottery::Draw;
    my $t = $ticket;
    die "FATAL: \$t is not a valid Ticket" unless $t ~~ PB-Lottery::Ticket;

    show-str-match :Lstr($d.numbers-str),  :Rstr($t.numbers-str);
    show-str-match :Lstr($d.numbers-str2), :Rstr($t.numbers-str);

    =begin comment
    my $Lset1a = $d.N.numbers5;
    my $Lset1b = $d.N.pb;
    my $Lset2a = $d.N2.numbers5;
    my $Lset2b = $d.N2.pb;

    my $Rset1a = $t.N.numbers5;
    my $Rset1b = $t.N.pb;

    my $Rset2a = $t.N.numbers5;
    my $Rset2b = $t.N.pb;

    # get the intersection of the numbers5 and pb for each set
    my $FRset1a = $Lset1a (&) $Rset1a;
    my $FRset1b = $Lset1b (&) $Rset1b;

    my $FRset2a = $Lset2a (&) $Rset2a;
    my $FRset2b = $Lset2b (&) $Rset2b;

    # those intersections determine which LHS and RHS numbers
    # get an "underline" character
    my @nums51a = $FRset1a.keys.sort({});
    my @nums52a = $FRset22.keys.sort({});
    =end comment

} # end sub show-ticket-matches

sub show-str-match(
    :$Lstr!,
    :$Rstr!,
    :$debug,
) {
    say "DEBUG: in sub show-str-match" if 1 or $debug;

    # $d.numbers-str, $t.numbers-str => output: the two lines above
    # we will need the raw strings and pieces
    my @lw = $Lstr.words[0..^6]; # includes the PB word
    my @rw = $Rstr.words[0..^6]; # includes the PB word

    my $lset5 = str2intlist(@lw[0..^5].join(' ')).Set;
    die "FATAL: \$lset5 is not a Set" unless $lset5 ~~ Set;

    my $lsetp = str2intlist(@lw[5].join(' ')).Set;
    die "FATAL: \$lsetp is not a Set" unless $lsetp ~~ Set;

    my $rset5 = str2intlist(@rw[0..^5].join(' ')).Set;
    die "FATAL: \$rset5 is not a Set" unless $rset5 ~~ Set;

    my $rsetp = str2intlist($Rstr.words[5].join(' ')).Set;
    die "FATAL: \$rsetp is not a Set" unless $rsetp ~~ Set;

    # get the two intersections
    my $s5 = $lset5 (&) $rset5;
    my @s5nums = $s5.keys.sort({ $^a <=> $^b });
    my $sp = $lsetp (&) $rsetp;
    my @spnums = $sp.keys.sort({ $^a <=> $^b });

    # back to strings to mod and remove all but
    # the matched numbers

    # the four original number strings
    my $lmatch5 = @lw[0..^5].join(' ');
    my $lmatchp = @lw[5].join(' ');
    my $rmatch5 = @rw[0..^5].join(' ');
    my $rmatchp = @rw[5].join(' ');

    # copies to modify
    my $lm5 = $lmatch5;
    my $lmp = $lmatchp;

    my $rm5 = $rmatch5;
    my $rmp = $rmatchp;

    for @s5nums -> $w {
        # $w is a matched number
        # it should have 2 chars
        my $n = $w.chars;
        die "\$w '$w' MUST have 2 chars, but it has $n" unless $n == 2;
        # eliminate the UNmatched numbers
        if $lm5 ~~ /$w/ {
            ; # ok, # a no-op
        }
        else {
            # remove and substitute 2 spaces
            $lm5 ~~ s/$w/  /; # substitute 2 spaces
        }
        if $rm5 ~~ /$w/ {
            ; # ok, # a no-op
        }
        else {
            # remove and substitute 2 spaces
            $rm5 ~~ s/$w/  /; # substitute 2 spaces
        }
    }

    for @spnums -> $w {
        # $w is a matched number
        # it should have 2 chars
        my $n = $w.chars;
        die "\$w MUST have 2 chars, but it has $n" unless $n == 2;

        # eliminate the UNmatched numbers
        if $lmp ~~ /$w/ {
            ; # ok, # a no-op
        }
        else {
            # remove and substitute 2 spaces
            $lmp ~~ s/$w/  /; # substitute 2 spaces
        }
        if $rmp ~~ /$w/ {
            ; # ok, # a no-op
        }
        else {
            # remove and substitute 2 spaces
            $rmp ~~ s/$w/  /; # substitute 2 spaces
        }
    }

    =begin comment
    my $lm5 = $lmatch5;
    my $lmp = $lmatchp;

    my $rm5 = $rmatch5;
    my $rmp = $rmatchp;
    =end comment

    print "$lm5 $lmp | $rm5 $rmp"; say();



} # end sub show-str-match
