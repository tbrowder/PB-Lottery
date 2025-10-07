unit module PB-Lottery;

my $F = $?FILE.IO.basename;

use Text::Utils :strip-comment;
use Test;

use PB-Lottery::Subs;
use PB-Lottery::Draw;
use PB-Lottery::Ticket;
use PB-Lottery::Numbers;
use PB-Lottery::Vars;
use PB-Lottery::Subs;

sub calc-part-winnings(
    PB-Lottery::Ticket :$ticket!, #= the ticket object
    PB-Lottery::Draw   :$draw!,   #= the draw object
    :$part! where * ~~ /1|2/,
    :$debug,
    --> Numeric #= return part winnings for this ticket/draw combo
) is export {
    
    my $cash = 0;
    my @dnums;
    # If part == 1, check the user's ticket against the power ball ticket
    # If part == 2, check the user's ticket against the the double play ticket

    # TODO this should be a simple matter of comparing two sets
    #      modify the two classes to already have the sets

    my $Nset = set(1..69);
    my $Pset = set(1..26);

    # the PB-Lottery::Numbers objects
    my $tn5set = $ticket.N.numbers5;
    my $tpbset = $ticket.N.pb;

    my ($dn5set, $dpbset);
    my ($n5set, $pbset);
    my ($nn, $np, $nx);

    # calc-dp-winnings
    if $part == 1 {
        # the power ball draw
        say "    Evaluating the power ball draw..." if 0 or $debug;
        $dn5set = $draw.N.numbers5;
        $dpbset = $draw.N.pb;

        # get the intersection of the draw and ticket sets
        $n5set = $tn5set (&) $dn5set;
        $pbset = $tpbset (&) $dpbset;

        $nn = $n5set.elems;
        $np = $pbset.elems;

        # get the Nx factor
        $nx = $draw.nx;
        
        if $nn or $np {
            if $debug {
            print qq:to/HERE/;
            The Powerball string: |{$draw.numbers-str}|
                $nn number matches of the Power Ball draw
                    $np match of its power ball
                Nx multiplier: $nx
            HERE
            }

            # get the coded prizes 
            my %h;
            my %pb-hash = ($nn or $np) ?? get-pb-hash() !! %h;
            my %pp-hash = ($nn or $np) ?? get-pp-hash() !! %h;

            # create the code for each
            my $pb-code = get-pb-code :$n5set, :$pbset;
            my $pp-code = get-pp-code :$n5set, :$pbset;

            # get the prize for each
            my $pb-prize = %pb-hash{$pb-code};
            my $pp-prize = %pp-hash{$pb-code};
        }
    }
    else {
        # the double play draw
        say "    Evaluating the double play draw..." if 0 or $debug;
        $dn5set = $draw.N2.numbers5;
        $dpbset = $draw.N2.pb;

        # get the intersection of the draw and ticket sets
        $n5set = $tn5set (&) $dn5set;
        $pbset = $tpbset (&) $dpbset;

        $nn = $n5set.elems;
        $np = $pbset.elems;

        if $nn or $np {
            if $debug {
            print qq:to/HERE/;
            The Double Play string: |{$draw.numbers-str2}|
                $nn number matches of the Double Play draw
                    $np match of its power ball
            HERE
            }

            # get the coded prizes 
            my %h;
            my %dp-hash = ($nn or $np) ?? get-dp-hash() !! %h;

            # create the code for each
            my $dp-code = get-dp-code :$n5set, :$pbset;

            # get the prize for each
            my $dp-prize = %dp-hash{$dp-code};
        }
    }
    $cash;
} # end sub calc-part-winnings

sub calc-winnings(
    PB-Lottery::Ticket :$ticket!, #= the ticket object
    PB-Lottery::Draw   :$draw!,   #= the draw object
    :$debug,
    --> Numeric #= return winnings for this ticket/draw combo
) is export {
    # Given a drawing set of numbers,
    # and a valid ticket for the drawing date,
    # calculate any winnings (may be estimates).

    # ensure we start with cash = 0
    my ($cash, $cash1, $cash2) = 0, 0, 0;

    $cash1 = calc-part-winnings :$ticket, :$draw, :part(1);
    $cash2 = calc-part-winnings :$ticket, :$draw, :part(2);
    $cash  = $cash1 + $cash2;

    =begin comment
    # calc-dp-winnings
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
        Our ticket: {$ticket.show.chomp} \# winnings: \$$cash
        HERE
    }
    else {
        print qq:to/HERE/;
        Our ticket: No winning tickets.
        HERE
    }
    =end comment

    $cash;
} # end sub calc-winnings

sub do-pick(
    $pdir, #= private directory
    :$debug,
) is export {
    say "Entering sub do-pick" if $debug;

    # pick and sort the first five numbers
    my @pick = (1..69).pick(5).sort({$^a cmp $^b});

    # add the power ball pick
    my $pick = (1..26).pick;
    @pick.push: $pick;
    say "pick 6: {@pick}" if 0 or $debug;

    # stringify for our use
    my ($s1, $s2);
    for @pick.kv -> $i, $n is copy {
        if $i {
            # add a space to the existing string
            $s1 ~= " ";
            $s2 ~= " ";
        }

        $s1 ~= $n;
        if $n.chars < 2 {
            # add a leading zero
            $n = "0$n";
        }
        $s2 ~= $n;
    }
    say "random: $s1" if $debug;
    say "random: $s2 # with 2 chars per number" if $debug;
}

sub do-enter-pick(
    $pdir, #= private directory
    :$debug,
) is export {
    say "Entering sub do-enter-pick" if $debug;
}

sub do-enter-draw(
    $pdir, #= private directory
    :$debug,
) is export {
    say "Entering sub do-enter-draw" if $debug;
    my $res = prompt "Enter date of the draw (yyyy-mm-dd): ";
    if  $res ~~ /^ \h* (\d\d\d\d '-' \d\d '-' \d\d) \h* $/ {
    }
    else {
        my $msg = "Invalid date entry: '$res'";
    }
}

sub do-status(
    $pdir, #= private directory
    :$all, #= show latest only unless true
    :$debug,
) is export {
    say "Entering sub do-status" if $debug;
    # read all the draws...
    say "Reading latest draw and associated valid tickets in directory:" if $debug;
    say "  $pdir" if $debug;

    my $dfil = "$pdir/draws.txt";
    my $tfil = "$pdir/my-tickets.txt";

    # create a sub to produce each of the list of Draw
    # and Ticket objects
    my @tickets = get-ticket-objects $tfil;
    my @draws   = get-draw-objects $dfil;

    say "Calculating winnings..." if $debug;

    my $cash = 0;
    for @tickets -> $ticket {
        for @draws -> $draw {
            # The calc subs are in this module...
            my $money = calc-winnings :$ticket, :$draw, :$debug;

            if $money {
                say "    Wow, ticket X won $money on draw on {$draw.date}" if $debug;
            }
            else {
                say "    Aw, ticket X won nothing on draw on {$draw.date}" if $debug;
            }

            $cash += $money;
        }
    }
    say "  Total winnings of \$$cash for the given lists." if $debug

} # end sub do-status

sub get-ticket-objects(
    $tfil,
    :$debug
    --> List
) is export {

    # read all the valid tickets (picks)...
    unless $tfil.IO.r {
        my $msg = "Ticket file '$tfil' not found.";
        throw-err $msg;
    }
    my @tlines = $tfil.IO.slurp.lines;

    if 0 or $debug {
        say "ticket lines:";
        say "  $_" for @tlines;
    }

    my @tickets = [];
    # 1  2  3  4  5  6  7          8  9  10 11   12
    # 03 06 20 34 49 12 2025-09-13 dp pb qp paid $dollars
    for @tlines.kv -> $i, $line is copy {
        $line = strip-comment $line;
        next unless $line ~~ /\S/;

        # one line per ticket
        my @words = $line.words;
        my $nw = @words.elems;
        unless $nw >= 8 {
            my $msg = "Invalid ticket line '$line'.\n";
            $msg ~= " It has $nw words but should have eight (8) or more";
            throw-err $msg;
        }

        # data for next Ticket object is complete
        my $ticket = PB-Lottery::Ticket.new: :numbers-str($line);
        unless $ticket ~~ PB-Lottery::Ticket {
            my $msg = "The intended ticket object failed to instantiate.";
            throw-err $msg;
        }

        @tickets.push: $ticket;
    } # end of the loop creating the valid Ticket objects

    unless @tickets.elems {
        my $msg = "Ticket file '$tfil' is empty.";
        throw-err $msg;
    }
} # end of sub get-ticket-objects

sub get-draw-objects(
    $dfil,
    :$debug
    --> List
) is export {
    my @dlines = $dfil.IO.slurp.lines;
    if 0 or $debug {
        say "draw lines:";
        say "  $_" for @dlines;
    }

    my @draws  = [];
    # two data lines per draw ticket
    my ($line1, $line2);

    $line1 = "";
    $line2 = "";
    # 1  2  3  4  5  6  7          8  9
    # 28 37 42 50 53 19 2025-09-13 ?x ?jackpot
    # 03 06 20 34 49 12 2025-09-13 dp
    for @dlines.kv -> $i, $line is copy {
        $line = strip-comment $line;
        next unless $line ~~ /\S/;

        my @words = $line.words;
        my $nw = @words.elems;
        unless (7 < $nw < 10)  {
            my $msg = "Invalid draw line '$line'.\n";
            $msg ~= " It has $nw words but should have 8 or 9";
            throw-err $msg;
        }

        if 0 or $debug {
            print qq:to/HERE/;
            DEBUG in file '$F'
                a draw line: |$line|
            HERE
        }

        if $line1 {
            # then this should be line2 and the data
            # for the next draw object is complete
            $line2 = $line;
            unless ($line1 ~~ /\S/) and ($line2 ~~ /\S/) {
                my $msg = "Unable to create a PB-Draw object with an empty line";
                throw-err $msg;
            }

            my $draw = PB-Lottery::Draw.new: :numbers-str($line1),
                                             :numbers-str2($line2);

            unless $draw ~~ PB-Lottery::Draw {
                my $msg = "Unable to instantiate a Draw object";
                throw-err $msg;
            }
            @draws.push: $draw;

            # finally, zero the two lines ready for the next draw
            $line1 = "";
            $line2 = "";
        }
        else {
            # this should be the first data line for
            # next draw object
            $line1 = $line;
        }
    } # end of creating a list of Draw objects

    unless @draws.elems {
        my $msg = "Draw file '$dfil' is empty.";
        throw-err $msg;
    }
} # end of sub get-draw-objects

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
            %!nums<a> = trim-leading-zeros +$0;
            %!nums<b> = trim-leading-zeros +$1;
            %!nums<c> = trim-leading-zeros +$2;
            %!nums<d> = trim-leading-zeros +$3;
            %!nums<e> = trim-leading-zeros +$4;
            %!nums<f> = trim-leading-zeros +$5; # the Power Ball
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
            $num += 1;
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
                    $pb-match += 1 if $dnum == $mnum;
                }
                elsif not $is-draw-power-ball {
                    $num-match += 1 if $dnum == $mnum;
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
