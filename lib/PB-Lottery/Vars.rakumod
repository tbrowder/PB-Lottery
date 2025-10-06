unit module PB-Lottery::Vars;

# Prizes for the Florida Powerball lottery
# in strings for decoding.

# the actual prizes possible for the various options

# sub get-pb-hash:
our @power-ball-prizes is export = [
"5+pb jackpot",
"5    1_000_000",
"4+pb 50_000",
"4    100",
"3+pb 100",
"3    7",
"2+pb 7",
"1+pb 4",
"pb   4",
];

# sub get-pp-hash:
our @power-play-prizes is export = [
"5+pb n/a",
"5    2_000_000",
"4+pb 100_000",
"4    200",
"3+pb 200",
"3    14",
"2+pb 14",
"1+pb 8",
"pb   8",
];

# sub get-dp-hash:
our @double-play-prizes is export = [
"5+pb 10_000_000",
"5    500_000",
"4+pb 50_000",
"4    500",
"3+pb 500",
"3    20",
"2+pb 20",
"1+pb 10",
"pb   7",
];
