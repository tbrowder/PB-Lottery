use Test;

my @modules = <
    PB-Lottery
    PB-Lottery::Subs
    PB-Lottery::Draw
    PB-Lottery::Ticket
    PB-Lottery::Vars
    PB-Lottery::Win
    PB-Lottery::Event
>;

plan @modules.elems;

for @modules {
    use-ok "$_", "Module '$_' can be used okay";
}
