#!/usr/bin/perl -I./lib/

use Test::Harness;

runtests(
    't/context.t',
    't/expression.t',
    't/expression/in.t',
    't/expression/defined.t',
    't/loader.t',
    't/template.t',
    't/filter/add.t',
    't/filter/escape.t',
    't/filter/join.t',
    't/filter/reverse.t',
    't/filter/safe.t',
    't/tag/autoescape.t',
    't/tag/comment.t',
    't/tag/cycle.t',
    't/tag/debug.t',
    't/tag/filter.t',
    't/tag/firstof.t',
    't/tag/firstofdefined.t',
    't/tag/for.t',
    't/tag/if.t',
    't/tag/ifchanged.t',
    't/tag/ifequal.t',
    't/tag/ifnotequal.t',
    't/tag/include.t',
    't/tag/load.t',
    't/tag/now.t',
    't/tag/regroup.t',
    't/tag/uncomment.t',
);