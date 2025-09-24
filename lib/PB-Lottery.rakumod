unit module PB-Lottery;

use Text::Utils :strip-comment;
use Test;

use PB-Lottery::Classes;
use PB-Lottery::Subs;

# use a class generator
sub SixNumberFactory(
    Str  $nums,
    Str  $nums2?, # if defined, this is the double play and this is a PB draw
    Date :$date,
    --> SixNumber
) is export {
    # Each call returns a single class object. The general process
    # should be:
    #   read all the valid owner tickets, getting a list of ticket
    #     objects
    #   read the draw numbers, geting a list of draw object
    #   check results of each ticket against each draw
    my $o;
    if $nums2.defined {
        $o = PB-Draw.new: :$nums, :$nums2, :$date;
    }
    else {
        $o = PB-Ticket.new: :$nums, :$date;
    }
    $o;
}

sub calc-part-winnings(
    :$tobj!, #= the ticket object
    :$dobj!, #= the draw object
    :$part! where * ~~ /1|2/,
    :$debug,
    --> Numeric #= return part winnings for this ticket/draw combo
) is export {
    my @dnums;
    # If part == 1, check the user's ticket against the power ball ticket
    # If part == 2, check the user's ticket against the the double play ticket
    if $part == 1 {
        # the power ball draw
        @dnums = $dobj.nums.keys.sort;
    }
    else {
        # the double play draw
        @dnums = $dobj.nums2.keys.sort;
    }
}

sub calc-winnings(
    :$tobj!, #= the ticket object
    :$dobj!, #= the draw object
    :$debug,
    --> Numeric #= return winnings for this ticket/draw combo
) is export {
    # Given a drawing set of numbers,
    # and a valid ticket for the drawing date,
    # calculate any winnings (may be estimates).

    # ensure we start with cash = 0
    my ($cash, $cash1, $cash2) = 0, 0, 0;;

    $cash1 = calc-part-winnings :$tobj, :$dobj, :part(1);
    $cash2 = calc-part-winnings :$tobj, :$dobj, :part(2);
    $cash  = $cash1 + $cash2;

=begin comment
    # calc-dp-winnings
    # rules are complicated
    # winning matches and prizes:

    # for the main draw:
    #   1 numbers + pb or just pb      $4
    #   2 numbers + pb or 3 numbers    $7
    #   3 numbers + pb or 4 numbers    $100
    #   4 numbers + pb                 $50,000
    #   5 numbers                      $1,000,000 # power play
    #   5 numbers + pb                 current jackpot

    # for the second draw for $1,000,000 # power play

    # the power ball draw
    my @pb = $dobj.nums.keys.sort;
    # the double play draw
    my @dp = $dobj.nums2.keys.sort;

    my @t = $tobj.nums.keys.sort;
    my $pb-match  = 0;
    my $num-match = 0;
    my $is-draw1-power-ball;
    my $is-draw2-power-ball;
    my $is-ticket-power-ball;

    # iterate over the ticket numbers
    TICKET: for @t -> $t {

        $is-ticket-power-ball = False;
        # keys: a..f
        if $d eq "f" {
            $is-ticket-power-ball = True;
        }

        for @t -> $t {
            $is-ticket-power-ball = False;
            # keys: a..f
            if $t eq "f" {
                $is-ticket-power-ball = True;
            }
            my $tnum = $tobj.nums{$k};

        #=== main play ===
        # iterate over the first draw set of numbers

        my $dnum = $dobj.nums{$d};

            # so so we have a Power Ball match or not?
            if $is-draw-power-ball and $is-self-power-ball {
                ++$pb-match if $dnum == $tnum;
            }
            elsif not $is-draw-power-ball {
                ++$num-match if $dnum == $tnum;
            }
            else {
                next;
                # no matches, so go to next user number
                # for this tickes
                die "FATAL: no pb match so what action to take?";
            }
        } # end of this ticket

        # analyze results...
        # winning matches and prizes:
        #   1 numbers + pb or just pb      $4
        #   2 numbers + pb or 3 numbers    $7
        #   3 numbers + pb or 4 numbers    $100
        #   4 numbers + pb                 $50,000
        #   5 numbers                      $1,000,000
        #   5 numbers + pb                 current jackpot
        if $pb-match {
            # auto win?
            # 0 or 1 num = $4
            # 2 nums = $7
            # 3 nums = $100
            # 4 nums = $50,000
            # 5 nums = current jackpot
            with $num-match {
                when $_ == 0 { $cash = 4 }
                when $_ == 1 { $cash = 4 }
                when $_ == 2 { $cash = 7 }
                when $_ == 3 { $cash = 100 }
                when $_ == 4 { $cash = 50_000 }
                when $_ == 5 { $cash = 2_000_000 } # jackpot
            }
        }
        elsif $num-match {
            # 3 nums = $7
            # 4 nums = $100
            # 5 nums = $1,000,000
            with $num-match {
                when $_ == 3 { $cash = 7 }
                when $_ == 4 { $cash = 100 }
                when $_ == 5 { $cash = 1_000_000 }
            }
        }

    } # end of this draw loop

    say "pb-match:  $pb-match"  if $debug;
    say "num-match: $num-match" if $debug;
    next unless $cash > 0; #$num-match or $pb-match;

    if $show-draw {
        print qq:to/HERE/;
          The draw  : {$dobj.show.chomp}
          Winning tickets
        HERE
    }
    if $cash > 0 {
        print qq:to/HERE/;
        Our ticket: {$tobj.show.chomp} \# winnings: \$$cash
        HERE
    }
    else {
        print qq:to/HERE/;
        Our ticket: No winning tickets.
        HERE
    }
=end comment
}

sub do-pick(
    $pdir, #= private directory
    :$debug,
) is export {
    say "Entering sub do-pick";
}

sub do-enter-pick(
    $pdir, #= private directory
    :$debug,
) is export {
    say "Entering sub do-enter-pick";
}

sub do-enter-draw(
    $pdir, #= private directory
    :$debug,
) is export {
    say "Entering sub do-enter-draw";
    my $res = prompt "Enter date of the draw (yyyy-mm-dd): ";
    if  $res ~~ /^ \h* (\d\d\d\d '-' \d\d '-' \d\d) \h* $/ {
    }
    else {
        print qq:to/HERE/;
        FATAL: Invalid date entry: '$res'.
               Exiting...
        HERE
        exit(1);
    }
}

sub do-status(
    $pdir, #= private directory
    :$all, #= show latest only unless true
    :$debug,
) is export {
    say "Entering sub do-status";
    # read all the draws...
    say "  Reading latest draw and associated valid tickets...";

    my $dfil   = "$pdir/draws.txt";
    my @dlines = $dfil.IO.slurp.lines;
    if 0 or $debug {
        say "draw lines:";
        say "  $_" for @dlines;
    }
    my @draws  = [];
    # two data lines per draw ticked
    my ($line1, $line2);

    $line1 = "";
    $line2 = "";
    # 28 37 42 50 53 19 2025-09-13 pb
    # 03 06 20 34 49 12 2025-09-13 dp
    for @dlines.kv -> $i, $line is copy {
        $line = strip-comment $line;
        next unless $line ~~ /\S/;

        my @words = $line.words;
        my $nw = @words.elems;
        unless $nw == 8 {
            print qq:to/HERE/;
            FATAL: Invalid draw line '$line'.
                     It has $nw words but should have eight (8).
                   Exiting...
            HERE
            exit(1);
        }

        if 0 or $debug {
            say "a draw line:";
            say "  $line";
        }

        if $line1 {
            # then this should be line2 and the data
            $line2 = $line;
            # for the next draw object is complete
            my $dobj = SixNumberFactory $line1, $line2;
            @draws.push: $dobj;

            # finally, zero the two lines ready for the next draw
            $line1 = $line2 = "";
        }
        elsif not $line1 {
            # this should be the first data line for
            # next draw object
            $line1 = $line;
        }
    }

    # read all the valid tickets (picks)...
    my $tfil   = "$pdir/my-tickets.txt";
    my @tlines = $tfil.IO.slurp.lines;

    $line1 = "";
    if 0 or $debug {
        say "ticket lines:";
        say "  $_" for @tlines;
    }
    my @tickets  = [];
    # 03 06 20 34 49 12 2025-09-13 dp pb qp
    for @tlines.kv -> $i, $line is copy {
        $line = strip-comment $line;
        next unless $line ~~ /\S/;

        # one line per ticket
        my @words = $line.words;
        my $nw = @words.elems;
        unless $nw >= 8 {
            print qq:to/HERE/;
            FATAL: Invalid draw line '$line'.
                     It has $nw words but should have at least eight (8).
                   Exiting...
            HERE
            exit(1);
        }

        # data for next ticket object is complete
        my $tobj = SixNumberFactory $line1;
        @tickets.push: $tobj;

        # reset $line1
        $line1 = "";
    }

    say "Calculating winnings...";

    my $cash = 0;
    for @tickets -> $tobj {
        for @draws -> $dobj {
            my $money = calc-winnings :$tobj, :$dobj, :$debug;
            $cash += $money;
        }
    }

} # end sub do-status

#=begin comment
=finish
# old stuff to steal from
sub get-multiple-powerball-plays(
    $nplays,
    :$debug,
    --> List
) is export {
    my @plays;
    for 1..$nplays {
        my $p = get-random-powerball-play;
        @plays.push: $p;
    }
    @plays
} # end sub get-multiple-powerball-plays

sub get-random-powerball-play(
    :$debug,
    --> Str
) is export {
    # uses a random seed saved in an envvar "PBALL_SEED"
    # to create:
    #   a set of 5 numbers from the set 1..69
    #   one Power Ball number from the set 1..26
    my (@num, $pball);
    @num = (1..69).pick(5);
    $pball = (1..26).pick;

    # sort the @num numerically
    @num = @num.sort({$^a cmp $^b});
    my $num = "";
    for @num.kv -> $i, $v is copy {
        if $v < 10 {
            $v = "0$v";
        }
        if $i > 0 {
            $v = " $v";
        }
        $num ~= $v;
    }
    $num ~= " $pball";
} # sub get-random-powerball-play

=finish
sub show-tickets(
    LNum :@tickets!,
    :$debug,
) is export {
} # end sub show-tickets

sub show-matches(
    LNum :@draws!,
    LNum :@tickets!,
    :$debug,
) is export {
} # end sub show-matches

sub show-draws(
    LNum :@draws!,
    :$debug,
) is export {
} # end sub show-draws

role Lottery is export {
    has Str  $.digits;  # "00 00 00 00 00 00"; # <= up to 6 numbers from 1..99
    has UInt $.ndigits; # depends on the type of game
    has Bool $.qp; # quick pick? # for history
    has Bool $.pp; # power play?
    has Bool $.dp; # double play?

    has Str  $.game  = "pb"; # Power Ball, others to be added
    has Str  $.state = "FL";
}

class LNum does Lottery is export {
    has Str $.entry is required; # n n n n n   N  date?
    has %.nums;
    has Date $.date;

    my $dt;

    my $debug = 0;
    sub trim-zeros($s is copy --> UInt) {
        if $s ~~ /^0/ {
            $s ~~ s/^0//;
        }
        $s;
    }

    submethod TWEAK {
        if $!entry ~~ /^
            \h* (\d+) # 0
            \h+ (\d+) # 1
            \h+ (\d+) # 2
            \h+ (\d+) # 3
            \h+ (\d+) # 4
            \h+ (\d+) # 5 the Power Ball

            # the date is now required
            # 6
            [\h+ (\d\d\d\d '-' \d\d '-' \d\d)]

            # three more optional, two-char entries
            # 7
            [\h+ (\w\w)]? # qp, dp, or pp
            # 8
            [\h+ (\w\w)]? # qp, dp, or pp
            # 9
            [\h+ (\w\w)]? # qp, dp, or pp


            \h*

            $/ {

            # need to trim leading zeros, if any
            %!nums<a> = trim-zeros +$0;
            %!nums<b> = trim-zeros +$1;
            %!nums<c> = trim-zeros +$2;
            %!nums<d> = trim-zeros +$3;
            %!nums<e> = trim-zeros +$4;
            %!nums<f> = trim-zeros +$5; # the Power Ball
            # the date is now mandatory
            $dt = ~$6;
            say "date = '$dt'" if $debug;
            $!date = Date.new: $dt;

            # the 3 optional entries 7, 8, 9
            if $7.defined {
                my $s = ~$7;
                if $s ~~ /:i qp /  { $!qp = True}
                if $s ~~ /:i dp /  { $!dp = True}
                if $s ~~ /:i pp /  { $!pp = True}
            }
            if $8.defined {
                my $s = ~$8;
                if $s ~~ /:i qp /  { $!qp = True}
                if $s ~~ /:i dp /  { $!dp = True}
                if $s ~~ /:i pp /  { $!pp = True}
            }
            if $9.defined {
                my $s = ~$9;
                if $s ~~ /:i qp /  { $!qp = True}
                if $s ~~ /:i dp /  { $!dp = True}
                if $s ~~ /:i pp /  { $!pp = True}
            }

        }
        else {
            say "FATAL: Unknown input format: '$!entry'";
            exit(1);
        }
    }

    method show($ticket-num?, :$debug, --> Str) {
        # show the ticket
        # tid x x x x x pb x
        my $id = "X";
        if $ticket-num.defined {
            $id = $ticket-num;
        }

        my @k = self.nums.keys.sort;
        my $t = "";
        my $num = 0;
        for @k -> $k {
            ++$num;
            # interject codes if applicable
            if $num == 1 {
                $t ~= " $id";
            }
            elsif $num == 6 {
                # print " PB";
                $t ~= " PB";
            }

            my $n = self.nums{$k};
            if $n.chars == 1 {
                # print "  $n";
                $t ~= "  $n";
            }
            else {
                # print " $n";
                $t ~= " $n";
            }
        }
        # print " # {self.date}";
        $t ~= " # {self.date}";
        # say();
    }

    method matches(LNum $draw, :$show-draw, :$debug) {
        # given a drawing set of six numbers, show the matched numbers
        # ensure we start with cash = 0
        my $cash = 0;

        # rules are complicated
        # winning matches and prizes:
        #   1 numbers + pb or just pb      $4
        #   2 numbers + pb or 3 numbers    $7
        #   3 numbers + pb or 4 numbers    $100
        #   4 numbers + pb                 $50,000
        #   5 numbers                      $1,000,000
        #   5 numbers + pb                 current jackpot

        my @d = $draw.nums.keys.sort;
        my @k = self.nums.keys.sort;
        my $pb-match  = 0;
        my $num-match = 0;
        my ($is-draw-power-ball, $is-self-power-ball);
        DRAW: for @d -> $d {
            $is-draw-power-ball = False;
            # keys: a..f
            if $d eq "f" {
                $is-draw-power-ball = True;
            }
            my $dnum = $draw.nums{$d};

            for @k -> $k {
                $is-self-power-ball = False;
                # keys: a..f
                if $k eq "f" {
                    $is-self-power-ball = True;
                }
                my $mnum = self.nums{$k};

                # so so we have a Power Ball match or not?
                if $is-draw-power-ball and $is-self-power-ball {
                    ++$pb-match if $dnum == $mnum;
                }
                elsif not $is-draw-power-ball {
                    ++$num-match if $dnum == $mnum;
                }
                else {
                    next;
                    # no matches, so go to next user number
                    # for this tickes
                    die "FATAL: no pb match so what action to take?";
                }
            } # end of this ticket

            # analyze results...
            # winning matches and prizes:
            #   1 numbers + pb or just pb      $4
            #   2 numbers + pb or 3 numbers    $7
            #   3 numbers + pb or 4 numbers    $100
            #   4 numbers + pb                 $50,000
            #   5 numbers                      $1,000,000
            #   5 numbers + pb                 current jackpot
            if $pb-match {
                # auto win?
                # 0 or 1 num = $4
                # 2 nums = $7
                # 3 nums = $100
                # 4 nums = $50,000
                # 5 nums = current jackpot
                with $num-match {
                    when $_ == 0 { $cash = 4 }
                    when $_ == 1 { $cash = 4 }
                    when $_ == 2 { $cash = 7 }
                    when $_ == 3 { $cash = 100 }
                    when $_ == 4 { $cash = 50_000 }
                    when $_ == 5 { $cash = 2_000_000 } # jackpot
                }
            }
            elsif $num-match {
                # 3 nums = $7
                # 4 nums = $100
                # 5 nums = $1,000,000
                with $num-match {
                    when $_ == 3 { $cash = 7 }
                    when $_ == 4 { $cash = 100 }
                    when $_ == 5 { $cash = 1_000_000 }
                }
            }

        } # end of this draw loop

        say "pb-match:  $pb-match"  if $debug;
        say "num-match: $num-match" if $debug;
        next unless $cash > 0; #$num-match or $pb-match;

        if $show-draw {
            print qq:to/HERE/;
              The draw  : {$draw.show.chomp}
              Winning tickets
            HERE
        }
        if $cash > 0 {
            print qq:to/HERE/;
            Our ticket: {self.show.chomp} \# winnings: \$$cash
            HERE
        }
        else {
            print qq:to/HERE/;
            Our ticket: No winning tickets.
            HERE
        }
    }

} # end of class LNum

our @picks is export = [
    # my Florida Lottery numbers (last number is Power Ball)
    # first 5 numbers are Florida Lottery, last number is the Power ball
    # a  b  c  d  e  f # <= %nums hash key
    #                    valid date
    #                    for pick   |<= Power Play
    #                                 |<= Double Play
    "18 30 37 45 56 18 2025-09-22 qp rp dp",
];
#=end comment
