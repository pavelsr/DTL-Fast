package DTL::Fast::Parser;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Renderer';

use DTL::Fast::Expression;
use DTL::Fast::Text;
use DTL::Fast::Template;

sub new
{
    my( $proto, %kwargs ) = @_;

    die 'No directory arrays passed into constructor'
        if not $kwargs{'dirs'}
            or ref $kwargs{'dirs'} ne 'ARRAY'
        ;
    
    die 'No raw chunks array passed into constructor'
        if not $kwargs{'raw_chunks'}
            or ref $kwargs{'raw_chunks'} ne 'ARRAY'
        ;
    
    $kwargs{'safe'} //= 0;
    
    my $self = $proto->SUPER::new(%kwargs)->parse_chunks();
    
    delete @{$self}{'raw_chunks'};
    
    return $self;
}

sub parse_chunks
{
    my( $self ) = @_;
    while( scalar @{$self->{'raw_chunks'}} )
    {
         $self->add_chunk( $self->parse_next_chunk());
    }
    return $self;
}

sub parse_next_chunk
{
    my( $self ) = @_;
    my $chunk = shift @{$self->{'raw_chunks'}};
    my $chunk_lines = scalar (my @tmp = $chunk =~ /(\n)/g ) || 0;
    #warn "Chunk $chunk, plus $chunk_lines lines";
    
    if( $chunk =~ /^\{\{\s*(.+?)\s*\}\}$/s )
    {
        if( $1 eq 'block.super' )
        {
            require DTL::Fast::Tag::BlockSuper;
            $chunk = DTL::Fast::Tag::BlockSuper->new(
                ''
                , 'dirs' => $self->{'dirs'}
            );
        }
        else
        {
            $chunk = DTL::Fast::Variable->new($1);
        }
    }
    elsif
    ( 
        $chunk =~ /^\{\%\s*([^\s]+?)(?:\s+(.*?))?\s*\%\}$/s
    )
    {
        $chunk = $self->parse_tag_chunk(lc $1, $2);
    }
    elsif
    ( 
        $chunk =~ /^\{\#.*\#\}$/s 
    )
    {
        $chunk = undef;
    }
    elsif( $chunk ne '' )
    {
        $chunk = DTL::Fast::Text->new( $chunk);
    }
    else
    {
        $chunk = undef;
    }
    
    $DTL::Fast::Template::CURRENT_TEMPLATE_LINE += $chunk_lines;
    
    return $chunk;
}

sub parse_tag_chunk
{
    my( $self, $tag_name, $tag_param ) = @_;
    
    my $result = undef;

    # dynamic module loading
    if( 
        not exists $DTL::Fast::TAG_HANDLERS{$tag_name} 
        and exists $DTL::Fast::KNOWN_TAGS{$tag_name} 
    )
    {
        require Module::Load;
        Module::Load::load($DTL::Fast::KNOWN_TAGS{$tag_name});
        $DTL::Fast::LOADED_MODULES{$DTL::Fast::KNOWN_TAGS{$tag_name}} = time;            
    }

    if( exists $DTL::Fast::TAG_HANDLERS{$tag_name} )
    {     
        $result = $DTL::Fast::TAG_HANDLERS{$tag_name}->new(
            $tag_param
            , 'raw_chunks' => $self->{'raw_chunks'}
            , 'dirs' => $self->{'dirs'}
        );
    }
    else
    {
        my $full_tag_name = join ' ', grep $_, ($tag_name, $tag_param);
        
        if ( # block tag parsing error
            $self->isa('DTL::Fast::Tag')
            and not $self->isa('DTL::Fast::Tag::Simple')
        ) 
        {
            warn $self->get_parse_error(
                sprintf( 'unknown tag {%% %s %%}', $full_tag_name )
                , sprintf( <<'_EOM_'
Possible reasons: typo, duplicated or unopened close tag {%% %1$s %%} at line %2$s
                  undisclosed block tag %3$s
_EOM_
                    , $tag_name // 'undef'
                    , $DTL::Fast::Template::CURRENT_TEMPLATE_LINE // 'unknown'
                    , $self->open_tag_syntax_with_line_number()
                )
            );
        }
        else # template parsing error
        {
            warn $self->get_parse_error(
                sprintf( 'unknown tag {%% %s %%}', $full_tag_name )
                , sprintf( <<'_EOM_'
Possible reasons: typo, duplicated or unopened close tag {%% %1$s %%} at line %2$s
_EOM_
                    , $tag_name // 'undef'
                    , $DTL::Fast::Template::CURRENT_TEMPLATE_LINE // 'unknown'
                )
            );
        }
        
        $result = DTL::Fast::Text->new();
    }
    
    return $result;
}

1;
