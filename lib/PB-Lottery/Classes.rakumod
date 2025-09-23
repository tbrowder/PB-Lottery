unit module PB-Lottery::Classes;

class SixNumber is export {
    has Str  $.nums;
    has Hash %.numsh;
}

class PB-Draw is SixNumber is export {
    has Str  $.nums2;
    has Hash %.nums2h;
    has Date $.date;
    submethod TWEAK {
    }
}

class PB-Ticket is SixNumber is export {
    has Date $.date;
    has Bool $.is-qp;
}


