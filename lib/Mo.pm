use 5.010;
package Mo;
use strict;
use warnings;

our $VERSION = '0.11';

use base 'Exporter';

our @EXPORT = qw(extends has);

sub import {
    my $class = $_[0];
    strict->import;
    warnings->import;
    no strict 'refs';
    push @{caller.'::ISA'}, $class;
    goto &Exporter::import;
}

sub new {
    my $class = shift;
    my $self = bless {@_}, $class;
    if ($self->can('BUILD')) { $self->BUILD }
    return $self;
}

no strict 'refs';

sub has {
    my $name = shift;
    *{caller."::$name"} = sub { @_-1 ? $_[0]->{$name} = $_[1] : $_[0]->{$name} };
}

sub extends { @{caller.'::ISA'} = $_[0] }

1;
