#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my @LAST_WARNING;
local $SIG{__WARN__} = sub { # here we get the warning
    @LAST_WARNING = @_;
#    print STDERR $_[0];
}; 

my $dirs = ['./t/tmpl'];
my( $template, $test_string, $context);

$template = get_template('error_tag.txt', 'dirs' => $dirs)->render();
ok( $LAST_WARNING[0] =~ /error_tag.txt/si, 'Unknown tag error message: template filename');
ok( $LAST_WARNING[0] =~ /, syntax began at line 5/si, 'Unknown tag error message: line number');
ok( $LAST_WARNING[0] =~ /duplicate/si, 'Unknown tag error message: possible reason');

$template = get_template('error_undisclosed.txt', 'dirs' => $dirs)->render();

ok( $LAST_WARNING[0] =~ /error_undisclosed.txt/si, 'Undisclosed tag error message: template filename');
ok( $LAST_WARNING[0] =~ /endif/si, 'Undisclosed tag error message: tag name');
ok( $LAST_WARNING[0] =~ /, syntax began at line 36/si, 'Undisclosed tag error message: line number');
ok( $LAST_WARNING[0] =~ /with/si, 'Undisclosed tag error message: possible cause, inner block');
ok( $LAST_WARNING[0] =~ /at line 21/si, 'Undisclosed tag error message: possible cause, inner block line number');

$template = get_template('error_unknown_filter.txt', 'dirs' => $dirs)->render();

ok($LAST_WARNING[0] =~ /error_unknown_filter.txt/si, 'Unknown filter error message: template filename');
ok($LAST_WARNING[0] =~ /unknown_something/si, 'Unknown filter error message: filter name');
ok($LAST_WARNING[0] =~ /, syntax began at line 36/si, 'Unknown filter error message: source line number');

eval{$template = get_template('error_double_empty.txt', 'dirs' => $dirs)->render();};
ok($@ =~ /\Qthere can be only one {% empty %} block\E/si, 'Double empty block message: error message');
ok($@ =~ /error_double_empty.txt/si, 'Double empty block message: template name');
ok($@ =~ /at line 46/si, 'Double empty block message: template line');
ok($@ =~ /\QDTL::Fast::Tag::For\E/si, 'Double empty block message: parent block');
ok($@ =~ /at line 42/si, 'Double empty block message: parent block line');

eval{$template = DTL::Fast::Template->new('{{var1|date:"D"}}');};
ok( $@ eq '', "Undef time value passed");

eval{get_template('error_variable_name.txt', 'dirs' => $dirs);};
ok( $@ =~ /\Qvariable `a=b` contains incorrect symbols\E/, 'Wrong variable name: error message');
ok( $@ =~ /\Qsyntax began at line 36\E/, 'Wrong variable name: error line');

eval{get_template('error_autoescape_bla.txt', 'dirs' => $dirs);};
ok( $@ =~ m{\Qautoescape tag undertands only `on` and `off` parameters\E}, 'Wrong autoescape parameter: error message');
ok( $@ =~ m{\Q./t/tmpl/error_autoescape_bla.txt, syntax began at line 41\E}, 'Wrong autoescape parameter: filename and line number');

eval{get_template('error_now_parameter.txt', 'dirs' => $dirs);};
ok( $@ =~ m{\Qno time format specified\E}, '`now` without a parameter: error message');
ok( $@ =~ m{\Q./t/tmpl/error_now_parameter.txt, syntax began at line 41\E}, '`now` without a parameter: filename and line number');

# expression
eval{get_template('error_expression_unpaired_brackets.txt', 'dirs' => $dirs);};
ok( $@ =~ m{\Qunpaired brackets in expression\E}, 'Unpaired brackets: error message');
ok( $@ =~ m{\Q./t/tmpl/error_expression_unpaired_brackets.txt, syntax began at line 36\E}, 'Unpaired brackets: filename and line number');
ok( $@ =~ m{\Q(2 > 1\E}, 'Unpaired brackets: expression');

eval{get_template('error_expression_binary_no_left.txt', 'dirs' => $dirs);};
ok( $@ =~ m{\Qbinary operator `>` has no left argument\E}, 'Missing left argument: error message');
ok( $@ =~ m{\Q./t/tmpl/error_expression_binary_no_left.txt, syntax began at line 36\E}, 'Missing left argument: filename and line number');
ok( $@ =~ m{\Q> 1\E}, 'Missing left argument: expression');

eval{get_template('error_expression_binary_no_right.txt', 'dirs' => $dirs);};
ok( $@ =~ m{\Qoperator `==` has no right argument\E}, 'Missing right argument: error message');
ok( $@ =~ m{\Q./t/tmpl/error_expression_binary_no_right.txt, syntax began at line 36\E}, 'Missing right argument: filename and line number');
ok( $@ =~ m{\Qa ==\E}, 'Missing right argument: expression');

eval{get_template('error_expression_unary_got_left.txt', 'dirs' => $dirs);};
ok( $@ =~ m{\Qunary operator `not` got left argument\E}, 'Extra left argument: error message');
ok( $@ =~ m{\Q./t/tmpl/error_expression_unary_got_left.txt, syntax began at line 36\E}, 'Extra left argument: filename and line number');
ok( $@ =~ m{\Qa not b\E}, 'Extra left argument: expression');

done_testing();
