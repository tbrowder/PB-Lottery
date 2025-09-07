use Test;

use lib "xt/lib";
use Helpers;

lives-ok { Okay; }, "Okay";

if 0 {
    lives-ok { Exit; }, "Exit";
    lives-ok { Leave; }, "Leave";
    lives-ok { Die; }, "Die";
} 
if 0 {
    dies-ok { Exit; }, "Exit";
    dies-ok { Leave; }, "Leave";
    dies-ok { Die; }, "Die";
}

done-testing;

