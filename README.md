[![Actions Status](https://github.com/tbrowder/PB-Lottery/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/PB-Lottery/actions) [![Actions Status](https://github.com/tbrowder/PB-Lottery/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/PB-Lottery/actions) [![Actions Status](https://github.com/tbrowder/PB-Lottery/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/PB-Lottery/actions)

NAME
====

**PB-Lottery** - Provides routines for handling play of US Power Ball lottery game

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

This program expects your two data files to be in a directory pointed to by the environment variable **PB_LOTTERY_PRIVATE_DIR**. That directory **must** exist in order for the program to run, and the `draws.txt` file must exist in order to check your results.

Note if you use the script to update any of those files it should create a '.bak' version of the base file. It should NOT continue any updates if that file already exists. It is recommended to keep your data files under *Git* management.

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

Note the Power Ball lottery's **draw** record is slightly different from the user's ticket entry. First, it has **two** lines per draw date. The **first** line is the actual 'Power Ball' draw plus the multiplier factor for the Power Play. The **second** line is the 'Double Play' draw. The two lines for each draw data **must** be in a text file in the following format (note two draw dates are shown):

    # Powerball lottery draws

    # draw on 2025-09-01
    08 23 25 40 53 05 2025-09-01 3x # <= the Power Ball draw & multiplier
    10 15 26 48 67 19 2025-09-01 dp # <= the Double Play draw

    # next draw
    # draw on 2025-09-03
    03 16 29 61 69 22 2025-09-03 2x # <= the Power Ball draw & multiplier
    07 32 39 50 61 04 2025-09-03 dp # <= the Double Play draw

Account data
------------

A third file is created to show results of the user's play. Its name is **my-financials.txt** and it shows total costs and other data for the period of play.

As of the writing, the cost of a ticket is $2. It costs $1 to add the Power Play option, and it costs $1 to add the Double Play option. Neither option depends upon the other.

Ticket costs
------------

The basic cost of a Power Ball lottery ticket is $2. The Florida Lottery offers optional add-ons to increase potential winnings (other states may offer similar options) but the author has not attempted to handle any other state's programs).

**Table 1.**

<table class="pod-table">
<thead><tr>
<th>Add-on</th> <th>Cost</th> <th>Function</th>
</tr></thead>
<tbody>
<tr> <td>Power Play</td> <td>+1$ per play</td> <td>Multiplies non-jackpot prizes 2, 3, 4, 5, or even 10 times, depending upon on the multiplier drawn. A Match 5 prize with Power Play is automatically increased to $2 million.</td> </tr> <tr> <td>Double Play</td> <td>+1$ per play</td> <td>Gives you a second chance to win with your same numbers in a separate drawing that occurs right after the main Powerball drawing. This feature has a top prize of $10 million.</td> </tr>
</tbody>
</table>

Finding results
---------------

In the author's state of Florida, Power Ball lottery results can be found at [https://floridalottery.com](https://floridalottery.com). Other states will have their own lottery sites, but the results for any Power Ball lottery should be the same on each states' lottery site for the same date.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2025 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

