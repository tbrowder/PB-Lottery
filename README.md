[![Actions Status](https://github.com/tbrowder/PB-Lottery/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/PB-Lottery/actions) [![Actions Status](https://github.com/tbrowder/PB-Lottery/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/PB-Lottery/actions) [![Actions Status](https://github.com/tbrowder/PB-Lottery/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/PB-Lottery/actions)

NAME
====

**PB-Lottery** - Provides routines for handling play of the Florida Power Ball lottery game

SYNOPSIS
========

```raku
use PB-Lottery;
```

DESCRIPTION
===========

**PB-Lottery** is intended to help the user manage his or her play in the US Power Ball Lottery with draws every Monday, Wednesday, and Saturday.

It uses two separate data records, in defined formats (see below), for your tickets and the Power Ball drawings.

The drawing records must be in a file named `drawings.txt` and your ticket records must be in a file named `my-tickets.txt`.

This program expects your two data files to be in a directory pointed to by the environment variable **PB_LOTTERY_PRIVATE_DIR**.

Ticket file format
------------------

Your lottery ticket records must be in a text file in the following format:

    # Lottery number choices (picks)

    # The first five numbers are picks for the lottery, and the sixth and
    # last number is the Power Ball.

    # The seventh entry is the date the ticket is valid through and must
    # be in yyyy-mm-dd format.

    # The remainder of the ticket line may contain one, two, or three
    # optional two-character codes:

    #   pp  (for the 'Power Play' add-on option)
    #   dp  (for the 'Double Play' add-on option)
    #   qp  (for your records if you used the 'quick pick' method)

    # Any hash mark ('#') on a line starts a comment and
    # it and the # remainder of that line are ignored.
    # Blank lines are ignored.

    # A valid example:

     02 20 32 45 47 06 2025-09-22 pp dp qp

Draw file format
----------------

Note the Power Ball lotters **draw** record is slightly different and must be in a text file in the following format:

    # Florida Poweball draws

    # draw on 2025-09-01
    08 23 25 40 53 05 2025-09-01 pb # <= the Power Ball draw
    10 15 26 48 67 19 2025-09-01 dp # <= the Double Play draw

    # next draw
    # draw on 2025-09-03
    03 16 29 61 69 22 2025-09-03 pb
    07 32 39 50 61 04 2025-09-03 dp

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2025 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

