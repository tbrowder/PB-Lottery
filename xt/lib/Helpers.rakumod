unit module Helpers;

sub Die is export {
    die qq:to/HERE/;
    FATAL: Unrecognized format.
           Exiting with non-zero error code...
    HERE
}

sub Exit is export {
    print qq:to/HERE/;
    ERROR: Unrecognized format.
           Exiting with error code 1...
    HERE
    exit(1);
}

sub Leave is export {
    print qq:to/HERE/;
    WHOOPS: Unrecognized format.
            Gracefully exiting with error code 0...
    HERE
    exit(0);
}

