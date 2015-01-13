#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);
use Dotiac::DTL qw/Template Context/;

#
# In order to test Dotiac without caching, you need to modify Dotiac::DTL module
# and make %cache variable our instead of my
#
@Dotiac::DTL::TEMPLATE_DIRS = ('./tpl');
$Dotiac::DTL::CURRENTDIR = './tpl';

my $context = {
	'var1' => 'This',
	'var2' => 'is',
	'var3' => 'SPARTA',
	'var4' => 'GREEKS',
	'var5' => 'GO HOME!',
	'array1' => [qw( this is a text string as array )],
};

my $tpl = get_template(
    'root.txt',
    [ @Dotiac::DTL::TEMPLATE_DIRS ]
);
sub dtl_fast_render
{
   $tpl->render($context);
}

sub dtl_fast_parse
{
    %DTL::Fast::TEMPLATES_CACHE = ();
    %DTL::Fast::OBJECTS_CACHE = ();
    my $tpl = get_template(
        'root.txt',
        [ @Dotiac::DTL::TEMPLATE_DIRS ]
    );
}

my $t=Dotiac::DTL::Template('root.txt');
sub dtl_dotiac_render
{
    $t->string($context);
}

sub dtl_dotiac_parse
{
    %Dotiac::DTL::cache = ();
    my $t=Dotiac::DTL::Template('root.txt', -1);
}

sub dtl_fast_cgi
{
    system('perl cgi_dtl_fast.pl');
}

sub dtl_dotiac_cgi
{
    system('perl cgi_dtl_dotiac.pl');
}

print "IMPORTANT: In order to get proper results, you must alter Dotiac::DTL module and change my %cache definition to our %cache\n";

print "Saving results into files...\n";

open OF, '>', 'dtl_fast.txt';
print OF dtl_fast_render();
close OF;

open OF, '>', 'dtl_dotiac.txt';
print OF dtl_dotiac_render();
close OF;

print "Testing FCGI mode rendering...\n";

timethese( 3000, {
    'DTL::Fast  ' => \&dtl_fast_render,
    'Dotiac::DTL' => \&dtl_dotiac_render,
});


print "Testing FCGI mode parsing...\n";

timethese( 5000, {
    'DTL::Fast  ' => \&dtl_fast_parse,
    'Dotiac::DTL' => \&dtl_dotiac_parse,
});

print "Testing CGI mode...\n";

timethese( 300, {
    'Fast render   ' => \&dtl_fast_cgi,
    'Dotiac render ' => \&dtl_dotiac_cgi,
});