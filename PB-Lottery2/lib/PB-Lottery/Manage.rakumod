unit module PB::Lottery::Manage;

# Orchestrate subcommands and workflow.

use PB::Lottery::Parse;
use PB::Lottery::Format;
use PB::Lottery::Files;
use PB::Lottery::Hist;

sub run(Str $cmd, *@args) is export {
    given $cmd {
        when 'fetch'         { say "TODO: fetch PDF"; }
        when 'parse'         { say "TODO: parse latest PDF"; }
        when 'update'        { say "TODO: fetch + parse + hist"; }
        when 'hist'          { say "TODO: rebuild histogram"; }
        when 'check-tickets' { say "TODO: check tickets"; }
        when 'print'         { say "TODO: pretty print"; }
        default              { say "Usage: manage-pb <fetch|parse|update|hist|check-tickets|print>"; }
    }
}
