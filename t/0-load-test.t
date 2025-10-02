use Test;

my @modules = <
    PB-Lottery
    PB-Lottery::Subs
    PB-Lottery::Draw
    PB-Lottery::Nums
    PB-Lottery::Ticket
>;

plan @modules.elems;

for @modules {
    use-ok "$_", "Module '$_' can be used okay";
}
