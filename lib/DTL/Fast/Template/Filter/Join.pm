package DTL::Fast::Template::Filter::Join;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'join'} = __PACKAGE__;

use DTL::Fast::Template::Variable;
use DTL::Fast::Utils qw(html_protect);

#@Override
sub parse_parameters
{
    my $self = shift;

    confess "No separator passed to the filter ".__PACKAGE__
        if(
            ref $self->{'parameter'} ne 'ARRAY'
            or not scalar @{$self->{'parameter'}}
        );
        
    $self->{'sep'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
        
    return $self;    
}

#@Override
sub filter
{
    my $self = shift;
    my $filter_manager = shift;
    my $value = shift;
    my $context = shift;
    
    my $value_type = ref $value;
    my $result = undef;
    my $separator = $self->{'sep'}->render($context);
    
    my @source = ();
    if( $value_type eq 'HASH' )
    {
        @source = (%$value);
    }
    elsif( $value_type eq 'ARRAY' )
    {
        @source = @$value;
    }
    else
    {
        confess sprintf( "Unable to apply filter %s to the %s value"
            , __PACKAGE__
            , $value_type || 'SCALAR'            
        );
    }    
    
    if( $filter_manager->{'safeseq'} )
    {
        $separator = html_protect($separator) 
            if not $context->get('_dtl_safe');
            
        $filter_manager->{'safe'} = 1;
    }
    
    return join $separator, @source;
}

1;