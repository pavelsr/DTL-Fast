package DTL::Fast::Template::Expression::Operator::Binary::Pow;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Binary';

$DTL::Fast::Template::Expression::Operator::KNOWN{'**'} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);
    my $result = 0;
    
    if( looks_like_number($arg1) and looks_like_number($arg2))
    {
        $result = ($arg1 ** $arg2);
    }
    elsif( $arg1_type and $arg1->can('pow'))
    {
        $result = $arg1->pow($arg2);
    }
    else
    {
        die "Don't know how to involute $arg1 ($arg1_type) to power of $arg2 ($arg2_type)";
    }
    
    return $result;
}

1;