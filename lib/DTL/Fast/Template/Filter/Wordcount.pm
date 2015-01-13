package DTL::Fast::Template::Filter::Wordcount;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'wordcount'} = __PACKAGE__;

#@Override
sub filter
{
    shift;  # self
    shift;  # filter_manager
    my $value = shift;
    shift;  # context

    return scalar (my @tmp = split /\s+/s, $value);    # Perl 5.10 compatibility, marks deprecated implicit split
}

1;