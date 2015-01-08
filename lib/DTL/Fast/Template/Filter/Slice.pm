package DTL::Fast::Template::Filter::Slice;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'slice'} = __PACKAGE__;

use DTL::Fast::Template::Variable;

#@Override
sub parse_parameters
{
    my $self = shift;
    die "No slicing settings specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'settings'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    my $settings = $self->{'settings'}->render($context);
    
    if( ref $value eq 'ARRAY' )
    {
        $value = $self->slice_array($value, $settings);
    }
    elsif( ref $value eq 'HASH' )
    {
        $value = $self->slice_hash($value, $settings);
    }
    else
    {
        die sprintf(
            "Can slice only HASH or ARRAY, not %s (%s)"
            , $value // 'undef'
            , ref $value || 'SCALAR'
        );
    }
    
    return $value;
}

sub slice_array
{
    my $self = shift;
    my $array = shift;
    my $settings = shift;
    
    my $start = 0;
    my $end = $#$array;
    
    if( $settings =~ /^([-\d]+)?\:([-\d]+)?$/ ) # python's format
    {
        $start = $self->python_index_map($1, $end) // $start;
        $end = defined $2 ? 
            $self->python_index_map($2, $end) - 1
            : $end;
    }
    elsif( $settings =~ /^([-\d]+)?\s*\.\.\s*([-\d]+)?$/ ) # perl's format
    {
        $start = $1 // $start;
        $end = $2 // $end;
    }
    else
    {
        die "Array slicing option MUST be specified in Python's or Perl's format: [from_index]:[to_index+1] or [from_index]..[to_index]";
    }
    
    return [@{$array}[$start .. $end]];
}

sub python_index_map
{
    my $self = shift;
    my $pyvalue = shift;
    
    return $pyvalue if not defined $pyvalue;
    
    my $lastindex = shift;

    return $pyvalue < 0 ?
        $lastindex + $pyvalue + 1
        : $pyvalue;
}

sub slice_hash
{
    my $self = shift;
    my $hash = shift;
    my $settings = shift;
    
    return [@{$hash}{(split /\s*,\s*/, $settings)}];
}

1;