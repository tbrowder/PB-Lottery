unit module PB::Lottery::Files;

# Atomic file IO helpers and path utilities.

sub atomic-write(Str $path, Str $content --> Bool) is export {
    # TODO: write to $path.tmp, fsync, rename to $path
    ...
}

sub read-draws(Str $path --> Array) is export {
    # TODO: read draws.txt and return parsed records
    ...
}
