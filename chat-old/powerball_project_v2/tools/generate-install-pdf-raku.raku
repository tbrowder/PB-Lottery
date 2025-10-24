#!/usr/bin/env raku
use v6;

sub MAIN(:$md='INSTALL.md', :$out='INSTALL.pdf', :$name='Thomas Browder', :$date='October 2025') {
    my $mdpath = $md.IO; die "Missing $md" unless $mdpath.e;
    my $use-document = False;
    try { EVAL 'use PDF::Document'; $use-document = True; CATCH { default { } } }
    my $use-lite = False;
    unless $use-document { try { EVAL 'use PDF::Lite'; $use-lite = True; CATCH { default { } } } }
    die "Need PDF::Document or PDF::Lite" unless $use-document || $use-lite;

    my @lines = $mdpath.slurp(:enc('utf8')).lines;
    my @toc; for @lines -> $l { if $l ~~ /^ '# ' (.*) $/ { @toc.push: { :lvl(1), :title($0.Str.trim) } }
                                 elsif $l ~~ /^ '## ' (.*) $/ { @toc.push: { :lvl(2), :title($0.Str.trim) } } }
    class Block { has Str $.type; has Str $.text; has @.lines }
    my @blocks; my $code = False;
    for @lines -> $l {
        if $l ~~ /^ \s* '```' / { $code = !$code; if $code { @blocks.push: Block.new(:type<code>, :lines([])) } ; next }
        if $code { @blocks[*-1].lines.push: $l; next }
        if $l ~~ /^ '# ' (.*) $/   { @blocks.push: Block.new(:type<h1>, :text($0.Str.trim)); next }
        if $l ~~ /^ '## ' (.*) $/  { @blocks.push: Block.new(:type<h2>, :text($0.Str.trim)); next }
        if $l ~~ /^ '### ' (.*) $/ { @blocks.push: Block.new(:type<h3>, :text($0.Str.trim)); next }
        if $l ~~ /^ '-' \s+ (.*) $/ { @blocks.push: Block.new(:type<li>, :text($0.Str.trim)); next }
        if $l.trim eq '' { @blocks.push: Block.new(:type<sp>, :text('')); next }
        @blocks.push: Block.new(:type<p>, :text($l));
    }

    my $W=612; my $H=792; my $M=54; my $CW = $W-2*$M;

    my @pages; my @gfx;
    class Canvas {
        has $.impl; has $.mode; has $.W; has $.H; has $.M; has $.CW; has $.y;
        method new-page() {
            my $p; my $g;
            if $.mode eq 'doc' { $p=$.impl.add-page; $g=$p.add-content } else { $p=$.impl.add-page; $g=$p.graphics }
            @pages.push: $p; @gfx.push: $g; $.y = $.H - $.M;
        }
        method font($n,$s){ $.mode eq 'doc' ?? @gfx[*-1].set-font(:name($n), :size($s)) !! @gfx[*-1].font(:name($n), :size($s)) }
        method text($t,$x,$y){ @gfx[*-1].text($t, :at($x,$y)) }
        method line($x1,$y1,$x2,$y2){ my $g=@gfx[*-1]; $g.move-to($x1,$y1); $g.line-to($x2,$y2); $g.stroke }
        method box($x,$y,$w,$h){ my $g=@gfx[*-1]; $g.rectangle($x,$y,$w,$h); $g.stroke }
    }

    my $pdf; my $mode; if $use-document { $pdf=PDF::Document.new; $mode='doc' } else { $pdf=PDF::Lite.new; $mode='lite' }
    my $c = Canvas.new(:impl($pdf), :mode($mode), :W($W), :H($H), :M($M), :CW($CW));

    # Cover
    $c.new-page;
    $c.font('FreeSerif Bold',24); $c.text("Powerball Automation Package v2", $W/2 - 200, $H - 144);
    $c.font('FreeSerif',13); $c.text("Installation & Operations Guide", $W/2 - 200, $H - 166);
    $c.line($M, $H - 208, $W - $M, $H - 208);
    $c.font('FreeSerif',10);
    $c.text("Automated Powerball Data Collection, Parsing, and Scheduling for Linux Systems", $M, $H - 230);
    $c.text("Prepared for " ~ $name ~ " – " ~ $date, $W/2 - 120, 72);

    # TOC
    $c.new-page; $c.font('FreeSerif Bold',18); $c.text("Table of Contents", $M, $c.y);
    my $y=$c.y - 24; $c.font('FreeSerif',11);
    for @toc -> %e { my $ind = %e<lvl>==1 ?? 0 !! 16; $c.text((" " x $ind) ~ %e<title>, $M, $y); $y-=16; if $y<90 { $c.new-page; $c.font('FreeSerif',11); $y=$c.y } }

    # Body
    $c.new-page; $y = $c.y;
    sub wrap($txt,$size){ my $maxc = ($CW / ($size*0.5)).Int max 20; my @o; my $t=$txt;
        while $t.chars > $maxc { my $pos=$t.substr(0,$maxc).rindex(' '); $pos=$maxc if $pos<20; @o.push:$t.substr(0,$pos).trim-trailing; $t=$t.substr($pos).trim-leading }
        @o.push:$t if $t.chars; @o }
    for @blocks -> $b {
        given $b.type {
            when 'sp' { $y -= 8 }
            when 'h1' { $c.font('FreeSerif Bold',18); for wrap($b.text,18) -> $ln { if $y<90 { $c.new-page; $y=$c.y; $c.font('FreeSerif Bold',18) } ; $c.text($ln,$M,$y); $y-=22 } }
            when 'h2' { $c.font('FreeSerif Bold',14); for wrap($b.text,14) -> $ln { if $y<90 { $c.new-page; $y=$c.y; $c.font('FreeSerif Bold',14) } ; $c.text($ln,$M,$y); $y-=18 } }
            when 'h3' { $c.font('FreeSerif Bold',12); for wrap($b.text,12) -> $ln { if $y<90 { $c.new-page; $y=$c.y; $c.font('FreeSerif Bold',12) } ; $c.text($ln,$M,$y); $y-=16 } }
            when 'li' { $c.font('FreeSerif',11); for wrap("• " ~ $b.text,11) -> $ln { if $y<90 { $c.new-page; $y=$c.y; $c.font('FreeSerif',11) } ; $c.text($ln,$M+10,$y); $y-=14 } }
            when 'code' {
                $c.font('FreeMono',10); my $top=$y;
                for $b.lines -> $ln { for wrap($ln,10) -> $wl { if $y<100 { $c.new-page; $y=$c.y; $c.font('FreeMono',10); $top=$y } ; $c.text($wl,$M+8,$y); $y-=13 } }
                $c.box($M+4,$y+6,$CW-8,$top-$y+6); $y-=6;
            }
            default { $c.font('FreeSerif',11); for wrap($b.text,11) -> $ln { if $y<90 { $c.new-page; $y=$c.y; $c.font('FreeSerif',11) } ; $c.text($ln,$M,$y); $y-=14 } }
        }
    }

    # Second pass: header + page numbers on non-cover pages
    my $total = +@pages;
    my $title = 'Powerball Automation Package v2 – Installation & Operations Guide';
    for @pages.kv -> $idx, $p {
        next if $idx == 0;  # skip cover
        my $g = @gfx[$idx];
        # header
        if $use-document { $g.set-font(:name('FreeSerif'), :size(9)) } else { $g.font(:name('FreeSerif'), :size(9)) }
        $g.text($title, :at($M, $H - $M + 12));
        # footer
        my $label = "Page { $idx + 1 } of { $total }";
        my $x = $W - $M - 120; my $y = $M - 18;
        $g.text($label, :at($x,$y));
    }

    $pdf.save-as($out);
    say "Wrote {$out}";
}
