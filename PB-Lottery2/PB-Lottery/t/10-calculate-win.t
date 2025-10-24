use v6;
use Test;

use lib 'lib';

use PB::Lottery::Win :ALL;
use PB::Lottery::Calculate :ALL;

# Minimal stand-in classes for testing
class Ticket {
    has @.numbers;
    has Int $.powerball;
    has Bool $.power-play = False;
    has Bool $.double-play = False;
    method new(:@numbers!, :$powerball!, :$power-play = False, :$double-play = False) {
        self.bless(:@numbers, :$powerball, :$power-play, :$double-play);
    }
}

class Draw {
    has @.numbers;
    has Int $.powerball;
    has @.double-numbers;
    has Int $.double-powerball;
    has Int $.power-play = 2;
    method new(:@numbers!, :$powerball!, :@double-numbers = (), :$double-powerball = 0,
               :$power-play = 2) {
        self.bless(:@numbers, :$powerball, :@double-numbers, :$double-powerball, :$power-play);
    }
}

subtest 'basic 3+PB win and power play' => {
    my $ticket = Ticket.new(
        :numbers(1, 2, 3, 10, 20),
        :powerball(9),
        :power-play(True),
    );
    my $draw = Draw.new(
        :numbers(3, 2, 30, 40, 50),
        :powerball(9),
        :power-play(3),
    );
    my $win = calculate-win($ticket, $draw);
    is $win.pb, 100, 'pb base payout for 3+PB is 100';
    is $win.pp, 200, 'pp adds (multiplier-1)*pb = (3-1)*100 = 200';
    is $win.dp, 0,   'no double play when not selected';
    is $win.total, 300, 'total sums pb+pp+dp';
}

subtest 'double play path' => {
    my $ticket = Ticket.new(
        :numbers(4, 5, 6, 7, 8),
        :powerball(11),
        :double-play(True),
    );
    my $draw = Draw.new(
        :numbers(10, 20, 30, 40, 50),
        :powerball(1),
        :double-numbers(4, 14, 24, 34, 44),
        :double-powerball(11),
    );
    my $win = calculate-win($ticket, $draw);
    is $win.pb, 0,    'no base win on main draw';
    is $win.dp, 7,    'dp payout for 0+PB is 7';
    is $win.total, 7, 'total reflects only dp payout';
}

done-testing;
