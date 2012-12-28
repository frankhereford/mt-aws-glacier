#!/usr/bin/perl

use TAP::Harness;
use strict;
use warnings;
use utf8;

my $harness = TAP::Harness->new({
    formatter_class => 'TAP::Formatter::Console',
    merge           => 1,
 #   verbosity       => 1,
    normalize       => 1,
    color           => 1,
    jobs			=> 8,
#    switches	=> '-MDevel::Cover'
});
$harness->runtests(
    'integration/journal.t',
    'integration/utf8_journal.t',
    'integration/utf8_line_protocol.t',
    'integration/utf8.t',
    'integration/t_treehash.t',
    'integration/metadata.t',
    'unit/journal_readjournal.t',
    'unit/journal_writejournal.t',
    'unit/journal_readfiles.t',
    'unit/journal_sanity.t',
    'unit/config_engine_parse.t',
    'integration/config_engine_v078.t',
);