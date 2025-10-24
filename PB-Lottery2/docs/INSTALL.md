# Powerball Lottery v3 (Simplified Skeleton)

This skeleton sets up the modern Powerball manager with clean module layout
and a minimal test framework. Modules live under `lib/PB-Lottery/*.rakumod`.

## Layout
```
lib/PB-Lottery/Format.rakumod
lib/PB-Lottery/Parse.rakumod
lib/PB-Lottery/Files.rakumod
lib/PB-Lottery/Hist.rakumod
lib/PB-Lottery/Manage.rakumod
bin/manage-pb
t/
docs/INSTALL.md
META6.json
```

## CLI
```
raku bin/manage-pb fetch
raku bin/manage-pb parse
raku bin/manage-pb update
raku bin/manage-pb hist
raku bin/manage-pb check-tickets
```

Run tests with:
```
zef test -v .
```
