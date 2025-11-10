unit module PB-Lottery::ExtractBlocks;

use JSON::Fast;

sub iso-to-weekday(Str $iso --> Str) {
    my ($year, $month, $day) = $iso.split('-')».Int;
    my $dt = DateTime.new(:$year, :$month, :$day);
    return <Mon Tue Wed Thu Fri Sat Sun>[$dt.day-of-week - 1];
}

sub fmt-block(
    @white, 
    Int $pb, 
    Str $date, 
    Str $suffix,
     --> Str
) is export {
    my @w = @white.map({ sprintf "%02d", $_ });
    my $pbp = sprintf "%02d", $pb;
    my $dow = iso-to-weekday($date);
    my $tail = $suffix.chars ?? " $suffix" !! '';
    return "{@w.join(' ')} {$pbp} {$date} {$dow}{$tail}";
}

sub parse-mmddyy(Str $mdy --> Str) {
    my @p = $mdy.split('/');
    die "bad date $mdy" unless @p.elems == 3;
    my ($m, $d, $y2) = @p».Int;
    my $y = 2000 + $y2;
    return sprintf "%04d-%02d-%02d", $y, $m, $d;
}

class Rec {
    has Str  $.date;
#   has @.nums;
    has @.numbers;
    has Int  $.pb;
    has Str  $.mult is rw;
    has Bool $.is-dp = False;
}

=begin comment
sub MAIN(
=end comment
sub extract-blocks(
    :$pdf-file1!,
    :$pdf-file2 = "/var/local/powerball/pb.pdf",

    :$last = 10,
    :$since = '',
    :$until = '',
    :$emit = 'blocks', #= blocks|json|both
#   :$pdf  = '',       #= local PDF path
#   :$pdf-url = 'https://files.floridalottery.com/exptkt/pb.pdf',
    :$debug,
) is export {

    # ensure we have the required system file
    my $which = run 'bash', '-lc', 'command -v pdftotext', :out, :err;
    die "pdftotext not found (install poppler-utils)" 
        if $which.exitcode != 0;

    # download location varies right now
    my $pdf-file;
    if $debug {
        $pdf-file = $*TMPDIR.IO.add('pb.pdf');
    }
    else {
        # downloaded by a cron job to:
        $pdf-file = "/var/local/powerball/pb.pdf";
    }

    say "DEBUG: See the input pdf file '$pdf-file'" if $debug;

    # create a text file from the PDF file
    my $txt-file = $*TMPDIR.IO.add('pb.txt');
    say "DEBUG: See pdf2txt file '$txt-file'" if $debug;
    my $pt = run 'pdftotext', '-layout', '-q', $pdf-file, 
                 $txt-file, :out, :err;
    die "pdftotext failed" if $pt.exitcode != 0;
    
    # parse the text file to get the latest draw data
    my @lines = $txt-file.open(:r, :enc('utf8-c8')).lines;
    my %by-date = Hash[Hash].new;

    say "DEBUG: lines from file '$txt-file'" if 0 or $debug;
    for @lines -> $line {
        say "  line: |$line|" if 0 or $debug;
        next unless $line ~~ /^ \s* (\d+ '/' \d+ '/' \d+) \s+ /;
        my $date = parse-mmddyy($0.Str);

        my @n = $line.comb(/\d+/); # the first 5 numbers
        next if @n.elems < 9;

        my @white = @n[3..7]».Int;
        my $pb    = @n[8].Int;
        my $mult  = '';
        if $line ~~ / <[Xx]> (\d+) / { 
            $mult = $0.Str ~ 'x' 
        }
        my $L = $line.uc.subst(/\s+/, ' ', :g);

        =begin comment
        10/25/25 2 12 22 39 67 PB 15 X2 POWERBALL

        10/25/25 3 24 46 58 61 PB 7 POWERBALL DP
        =end comment
        my $is-dp = $L.contains('POWERBALL DP') 
                    or $L.contains('DOUBLE PLAY');

        my $rec = Rec.new(
                      :date($date), 
                      :numbers(@white), 
                      :pb($pb), 
                      :mult($mult), 
                      :is-dp($is-dp)
                  );

        # empty the date
        %by-date{$date} //= {};
        #%by-date{$date} { $is-dp ?? 'dp' !! 'pb' } = $rec;
        if $is-dp {
            %by-date{$date}<dp> = $rec;
        }
        else {
            %by-date{$date}<pb> = $rec;
        }
    }
    say "DEBUG: found {%by-date.elems} dates." if 0 or $debug;

    my @blanks;
    my $clean = "pb.clean-txt";
    my $fh2 = open $clean, :w;
    my $nlines = 0;
    for $txt-file.lines -> $line is copy {
        if $line ~~ /\S/ {
            # collapse multiple spaces into one
            $line ~~ s:g/\h+/ /;  
            # any blank lines?
            if @blanks.elems {
                $fh2.say(); ++$nlines;
                @blanks = [];
            }
            $fh2.say: $line; ++$nlines;
        }
        else {
            # collapse multiple blank lines into one
            @blanks.push: "";
        }
    }
    $fh2.close;

    if 0 {
        say "temp end, see PB txt file '$txt-file'";
        say "    alse see cleaned PB txt file '$clean";
        say "    which has $nlines lines";
        exit(1);
    }
    if 1 {
        say "see PB txt file '$txt-file'";
        say "alse see cleaned PB txt file '$clean";
        say "    which has $nlines lines";
    }

    #=============================================
    # @dates has the desired number of text blocks
    #=============================================
    my $blocks-file = $*TMPDIR.IO.add('pb.blocks');
    my @dates = %by-date.keys.sort;
    if $last > 0 && @dates.elems > $last { 
        @dates = @dates[* - $last .. *] 
    }
    if $since ne '' { 
        @dates = @dates.grep(* ge $since); 
    }
    if $until ne '' { 
        @dates = @dates.grep(* le $until); 
    }

    if 1 or $debug {
        say "DEBUG: checking \@dates...";
        for @dates -> $date {
            say $date;
        }
    }

#   say "DEBUG: Early exit."; exit(1);

    #=============================================
    # @json has the corresponding JSON strings or objects
    #=============================================
    my $json-file = $*TMPDIR.IO.add('pb.json');
    my @json;
    my @blocks;
    for @dates -> $d {
        #if %by-date{$d}:exists('pb') {
        if %by-date{$d}<pb>:exists {
            my $r = %by-date{$d}<pb>;

            if $emit eq 'blocks' or $emit eq 'both' {
                #say fmt-block($r.nums, $r.pb, $d, $r.mult) ;
                my $b = fmt-block($r.numbers, $r.pb, $d, $r.mult) ;
                @blocks.push: $b;
            }
            if $emit eq 'json' or $emit eq 'both' {
                @json.push( 
                    draw_date => $d, 
                    numbers => $r.numbers, 
                    powerball => $r.pb,
                    multiplier => $r.mult.chars ?? $r.mult 
                                                !! Nil, 
                    source => 'floridalottery',
                    jackpot_usd => Nil,
                ); 
            }
        }

        if %by-date{$d}<dp>:exists {
            my $r = %by-date{$d}<dp>;

            if $emit eq 'blocks' or $emit eq 'both' {
                #say fmt-block($r.nums, $r.pb, $d, 'dp'); 
                my $b = fmt-block($r.numbers, $r.pb, $d, 'dp'); 
                @blocks.push: $b;
            }

            if $emit eq 'json' or $emit eq 'both' {
                @json.push(
                    draw_date => $d, 
                    numbers => $r.numbers, 
                    powerball => $r.pb,
                    multiplier => Nil, 
                    source => 'floridalottery dp', 
                    jackpot_usd => Nil,
                );
            }
        }
    }
    
    # convert the arrays to a file
    my $fh = open $blocks-file, :w;
    # two at a time delimited by blank lines
    #unless is-even @blocks.elems {
    unless @blocks.elems > 2 {
        die "FATAL: The blocks array has too few elements";
    }

    =begin comment
    # also put the last 10 in the private dir as 
    # file "draws-latest.txt"
    PB_LOTTERY_PRIVATE_DIR=
        /home/tbrowde/mydata/tbrowde-home/pb-lottery
    =end comment

    my $private-file = 0;
    my $private-dir = <PB_LOTTERY_PRIVATE_DIR>;
    if %*ENV{$private-dir}:exists {
        say "DEBUG: private-dir: '%*ENV{$private-dir}'" if 1 or $debug;
        $private-file = "{%*ENV{$private-dir}}/draws-latest.txt".IO;
        say "DEBUG: private-file: '$private-file'" if 1 or $debug;
    }
    else {
        say "WARNING: No private PB-Lottery found";
    }

    my $fh3 = $private-file ?? (open $private-file, :w) !! 0;
    while @blocks {
        $fh.say() if @blocks.elems; # blank line berween element
        $fh3.say() if $fh3 and @blocks.elems; # blank line berween element
        my $pb = @blocks.shift;
        my $dp = @blocks.shift;
        $fh.say("$pb # power ball draw");
        $fh.say("$dp # double play draw");
        $fh3.say("$pb # power ball draw") if $fh3;
        $fh3.say("$dp # double play draw") if $fh3;
        
    }
    $fh.close;
    $fh3.close if $fh3;

    say "DEBUG: See blocks file '$blocks-file'" if 1 or $debug;
    say "DEBUG: See private blocks file '$private-file'" if 1 or $debug;

    my $jstr;
    if ($emit eq 'json' or $emit eq 'both') { 
        #say to-json @json, :pretty 
        $jstr = to-json @json, :pretty;
        say $jstr;
    }
}
