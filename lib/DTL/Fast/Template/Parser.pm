package DTL::Fast::Template::Parser;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Renderer';
use Carp;

use DTL::Fast::Template::Expression;
use DTL::Fast::Template::Text;

sub new
{
    my $proto = shift;
    my %kwargs = @_;

    croak 'No directory arrays passed into constructor'
        if not $kwargs{'dirs'}
            or ref $kwargs{'dirs'} ne 'ARRAY'
        ;
    
    croak 'No raw chunks array passed into constructor'
        if not $kwargs{'raw_chunks'}
            or ref $kwargs{'raw_chunks'} ne 'ARRAY'
        ;
    
    $kwargs{'safe'} //= 0;
    $kwargs{'blocks'} = {};

    my $self = $proto->SUPER::new(%kwargs)->parse_chunks();
    
    delete @{$self}{'_template', '_container_block', 'raw_chunks'};
    
    return $self;
}

sub parse_chunks
{
    my $self = shift;
    while( scalar @{$self->{'raw_chunks'}} )
    {
         $self->add_chunk( $self->parse_next_chunk());
    }
    return $self;
}

sub parse_next_chunk
{
    my $self = shift;
    my $chunk = shift @{$self->{'raw_chunks'}};
    
#    warn "Processing chunk $chunk";
    if( $chunk =~ /^\{\{ (.+?) \}\}$/ )
    {
        $chunk = DTL::Fast::Template::Variable->new($1);
    }
    elsif
    ( 
        $chunk =~ /^\{\% ([^\s]+?)(?: (.*?))? \%\}$/ 
    )
    {
        $chunk = $self->parse_tag_chunk($1, $2);
    }
    elsif
    ( 
        $chunk =~ /^\{\# .* \#\}$/ 
    )
    {
        $chunk = undef;
    }
    elsif( $chunk )
    {
        $chunk = DTL::Fast::Template::Text->new( $chunk );
    }
    else
    {
        $chunk = undef;
    }
    
    return $chunk;
}

sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( exists $DTL::Fast::Template::TAG_HANDLERS{$tag_name} )
    {      
        $result = $DTL::Fast::Template::TAG_HANDLERS{$tag_name}->new(
            $tag_param
            , 'raw_chunks' => $self->{'raw_chunks'}
            , 'dirs' => $self->{'dirs'}
            , '_template' => $self->{'_template'} // $self
            , '_container_block' => $self->get_container_block()
        );
    }
    else
    {
        warn "Unknown tag: $tag_name";
        $result = DTL::Fast::Template::Text->new();
    }
    
    return $result;
}

sub get_container_block{ 
    return $_[0]->{'_container_block'} 
        // croak sprintf(
            "There is no container block in: %s", $_[0] // 'undef'
        ); 
}

sub add_blocks
{
    my $self = shift;
    my $blocks = shift;
    
    croak "Blocks must be a HASH reference" if ref $blocks ne 'HASH';
    
    foreach my $block_name (keys(%$blocks))
    {
        if( exists $self->{'blocks'}->{$block_name} )
        {
            croak "Block $block_name is already registered. Duplicate names are not allowed";
        }
        
        $self->{'blocks'}->{$block_name} = $blocks->{$block_name};
    }
    
    if( $self->{'_container'} )
    {
        $self->{'_container'}->add_blocks($blocks);
    }    
    
    return $self;
}

sub remove_block
{
    my $self = shift;
    my $block_name = shift;
    
    if( not exists $self->{'blocks'}->{$block_name} )
    {
        croak "Sub-block $block_name does not registered in current block.";
    }
    
    delete $self->{'blocks'}->{$block_name};
  
    if( $self->{'_container'} )
    {
        $self->{'_container'}->remove_block($block_name);
    }    
    
    return $self;
}

1;