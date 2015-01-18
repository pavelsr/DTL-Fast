package DTL::Fast::Tag::Spaceless;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';  
use Carp qw(confess);

$DTL::Fast::TAG_HANDLERS{'spaceless'} = __PACKAGE__;

#@Override
sub get_close_tag{return 'endspaceless';}

sub render
{
    my $self = shift;
    my $context = shift;
    
    my $result = $self->SUPER::render($context);
    
    DTL::Fast::spaceless($result);
    
    return $result;
}

1;