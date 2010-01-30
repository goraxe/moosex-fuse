package MooseX::Fuse::Dir;


use Moose::Role;
with 'MooseX::Fuse::Node';

use Data::Dumper;

has nodes => (
	traits => ['Hash'],
	is	=> 'ro',
	isa	=> 'HashRef[MooseX::Fuse::Node]',
	default => sub { return {}; },
	handles => {
		children => 'keys',
		remove   => 'delete',
		exists   => 'exists',
		get      => 'get',
	},
);


sub add {
	my ($self,$node, %args) = @_;
    
    $self->log_debug("add_node called with $node");
    return if not defined $node; 
    my $name = $args{name} || $node->name;

	$node->parent($self);
	die unless defined ($node->does('MooseX::Fuse::Node'));
	$self->nodes->{$name} = $node;
	return $node;
}

sub get {
	my ($self, $node) = @_;
	return  unless $self->has_nodes;

	my $paths;
	$self->log_debug ("translating $node");
	if (not ref $node) {
		$paths = $self->path_split($node);
	} elsif (ref ($node) eq 'ARRAY')  {
		$paths = $node;
	} else {
		die "unknown path type ". ref $node;
	}
	$self->log_debug("paths contains " . Dumper ($paths));
	my $path  = shift @$paths;
	$self->log_debug("looking up $path");
	return if (not defined $path);

	# if non existant path return
#	return if (not defined ($self->nodes()->{$path}));

    # recurse the call if we have more to drill down
    my $nodes = $self->nodes();
    my $child_node = $nodes->{$path};
    return  unless defined $child_node;
    if (@$paths > 0 ) {
        return $child_node->get(join "/", @$paths);
    }
    else {
        $self->log_debug("found node and returning it");
		return $child_node;
	}
}


no Moose;
1;
