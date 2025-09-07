unit module Helpers;

sub Okay is export {
    print qq:to/HERE/;
    NOTE: Unrecognized format.
          Continuing...
    HERE
}

sub Die is export {
    die qq:to/HERE/;
    FATAL: Unrecognized format.
           Exiting with non-zero error code...
    HERE
}

sub Exit($errcode = 0) is export {
    print qq:to/HERE/;
    ERROR: Unrecognized format.
           Exiting with error code $errcode...
    HERE
    exit($errcode);
}

sub Leave is export {
    print qq:to/HERE/;
    WHOOPS: Unrecognized format.
            Gracefully exiting with error code 0...
    HERE
    exit(0);
}
