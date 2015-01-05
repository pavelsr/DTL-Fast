package DTL::Fast::Template::Tag::Regroup;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'regroup'} = __PACKAGE__;

use DTL::Fast::Template::Variable;

#@Override
sub parse_parameters
{
    my $self = shift;

    if( $self->{'parameter'} =~ /^\s*(.+)\s+by\s+(.+?)\s+as\s+(.+?)\s*$/si )
    {
        @{$self}{qw( source grouper target_name)} = (
            DTL::Fast::Template::Variable->new($1)
            , $2
            , $3
        );
        
        confess "Grouper key can't be traversable: $2" if $2 =~ /\./;
        confess "Traget variable can't be traversable: $3" if $3 =~ /\./;
    }
    else
    {
        confess "Do not understand condition: $self->{'parameter'}";
    }
    
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;

    my $source_array = $self->{'source'}->render($context);
    
    if( 
        defined $source_array
        and ref $source_array eq 'ARRAY' 
    )
    {
        my @groupers = ();
        my $groups = {};
    
        foreach my $source (@$source_array)
        {
            if( 
                defined $source
                and ref $source eq 'HASH' 
            )
            {
                if( 
                    exists $source->{$self->{'grouper'}}
                    and defined (my $grouper = $source->{$self->{'grouper'}})
                )
                {
                    if( not exists $groups->{$grouper} )
                    {
                        push @groupers, $grouper;
                        $groups->{$grouper} = [];
                    }
                    push @{$groups->{$grouper}}, $source;
                }
                else
                {
                    die "Grouper value MUST exist and be defined in every source list item: $self->{'grouper'}";
                }
            }
        }
        
        my $grouped = [];
        
        foreach my $grouper (@groupers)
        {
            push @$grouped, {
                'grouper' => $grouper
                , 'list' => $groups->{$grouper}
            };
        }
        
        
        $context->set(
            $self->{'target_name'} => $grouped
        );
    }
    else
    {
        die sprintf( "Regroup can be applied to lists only: %s is a %s"
            , $self->{'source'}->{'original'}
            , ref $source_array
        );
    }
    
    return '';
}


1;