use Test;

use lib "xt/lib";
use Helpers;

if 0 {
    lives-ok { Exit; }, "Exit";
    lives-ok { Leave; }, "Leave";
    lives-ok { Die; }, "Die";
} 
else {
    dies-ok { Exit; }, "Exit";
    dies-ok { Leave; }, "Leave";
    dies-ok { Die; }, "Die";
}

done-testing;

