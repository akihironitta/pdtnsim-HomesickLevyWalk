#!/usr/bin/env perl
# 
# HomesickLevyWalk.pm
# A mobility class for Homesick Levy walk.
#

package DTN::Mobility::HomesickLevyWalk;

use List::Util qw(min max);
use Math::Vector::Real;
use Math::Random; 
use Math::Trig;
use Smart::Comments; use diagnostics;
use strict;
use warnings;
use parent qw(DTN::Mobility::LevyWalk);
use Class::Accessor::Lite ( rw => [ qw(homesick_probability home) ] );

# Generate a random variable with Pareto distribution. Mean of the
# Pareto distribution is given by shape * scale / (shape - 1).
sub pareto {
    my ( $scale, $shape ) = @_;
    return $scale / random_uniform( 1, 0, 1 / $shape );
}


# create and initialize the object
sub new {
    my ( $class, $opts_ref ) = @_;
    
    # define the homesick probability
    $opts_ref->{homesick_probability} //= 0.75; # homesick probability
    my $self = $class->SUPER::new($opts_ref);
    
    # set the object's initial coordinate and its home with the same coordinate.
    my $init_coordinate = $self->random_coordinate();
    $self->current( $init_coordinate );
    $self->home( $init_coordinate );
    
    # randomly set the object's first goal
    $self->{goal} = $self->random_coordinate();
    
    return $self;
}

# randomly choose the goal in the field so that the distance from the
# current coordinate follows Pareto distribution
sub goal_coordinate {
    my ($self) = @_;
    my $goal;
    if (random_uniform(1, 0, 1) < $self->{homesick_probability}) {
        $goal = $self->{home};
    }
    else {
        my $length = $self->pareto( $self->scale(), $self->shape() );
        my $theta = random_uniform( 1, 0, 2 * pi );
        $goal = $self->current() + $length * V( cos($theta), sin($theta) );
    }
    # FIXME: the goal coordinate is simply limited with the field
    # boundaries. A node should *bounce back* with the boundaries.
    return V(
        max( 0, min( $goal->[0], $self->width() ) ),
        max( 0, min( $goal->[1], $self->height() ) )
        );
} 1;
