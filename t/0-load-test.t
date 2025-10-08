use Test;

my @modules = <
    PB-Lottery
    PB-Lottery::Subs
    PB-Lottery::Draw
    PB-Lottery::Numbers
    PB-Lottery::Ticket
    PB-Lottery::Vars
>;

plan @modules.elems;

for @modules {
    use-ok "$_", "Module '$_' can be used okay";
}
