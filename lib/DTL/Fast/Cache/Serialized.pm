package DTL::Fast::Cache::Serialized;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache::Runtime';
use Carp;
use Storable;

#@Override
sub read_data
{
    my( $self, $key ) = @_;
    
    return 
        $self->deserialize(
            $self->read_serialized_data(
                $key
            )
        );
}

#@Override
sub write_data
{
    my( $self, $key, $data ) = @_;
    
    $self->write_serialized_data(
        $key,
        $self->serialize(
            $data
        )
    ) if defined $data; # don't store undef values
    return $self;
}

sub read_serialized_data
{ 
    my( $self, $key ) = @_;
    return $self->SUPER::read_data($key) 
};

sub write_serialized_data
{ 
    my( $self, $key, $data ) = @_;
    return $self->SUPER::write_data($key, $data) 
};

sub serialize
{
    my( $self, $data ) = @_;
    return if not defined $data;
    return Storable::freeze($data);
}

sub deserialize
{
    my( $self, $data ) = @_;
    return if not defined $data;
    return Storable::thaw($data);
}

1;