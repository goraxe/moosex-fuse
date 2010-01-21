package MooseX::Fuse::Node;

#use Moose;
use Moose::Role;

with 'MooseX::Log::Log4perl::Easy';

use Carp qw(croak carp);
use POSIX qw(ENOENT);
use Data::Dumper;

use constant {
	S_IFMT  => 0170000,
	S_IFSOCK=> 0140000,
	S_IFLNK => 0120000,
	S_IFREG => 0100000,
	S_IFBLK => 0060000,
	S_IFDIR => 0040000,
	S_IFCHR => 0020000,
	S_IFIFO => 0010000,
	S_ISUID => 0004000,
	S_ISGID => 0002000,
	S_ISVTX => 0001000,
};

has name => (
	is	=> 'ro',
	isa	=> 'Str',
);

has parent => (
    is  => 'rw',
    isa => 'MooseX::Fuse::Node',
);

has 'dev' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'inode' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'type' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	1
);

has 'rdev' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'blocks' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	1
);

has 'gid' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'uid' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'nlink' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	1
);

has 'blksize' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	1024
);

has 'atime' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'mtime' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'ctime' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=>	0
);

has 'size' => (
	is	=>	'rw',
	isa	=>	'Int',
	default	=>	0
);

has mode => (
    is => 'rw',
    isa => 'Int',
    default => 0755,
);

has nodes => (
	is	=> 'ro',
	isa	=> 'HashRef[MooseX::Fuse::Node]',
	lazy_build => 1
);

sub _build_nodes {
	return {};
}

has modes => (
    is  => 'ro',
    lazy_build => 1,
);


sub _build_modes {
    my ($self) = @_;
    return ($self->type << 9) + $self->mode;
}

#sub new {
#	my $class = shift;
#	my $opts =  (@_ % 2) ?  { name => shift } :  {@_} ;
#
#	$opts->{nodes} = {};
#
#	# check required parms 
#	foreach my $key (qw(name)) {
#		if (not exists($opts->{$key})) {
#			croak "$key is a required option";
#		}
#	}
#
#	# set defaults
#	foreach my $key (keys %$defaults) {
#		next if (exists ($opts->{$key}));
#		$opts->{$key} = $defaults->{$key};
#	}
#
#	return bless ($opts, $class);
#}
#
#>---$file->{stat} = [$dev,$ino,$modes,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks];@
#sub stat {
#	
#}


sub stat {
    my ($self) = @_;
    return ($self->dev,$self->inode,$self->modes,$self->nlink,$self->uid,$self->gid,$self->rdev,$self->size,$self->atime,$self->mtime,$self->ctime,$self->blksize,$self->blocks);
}

# support adding just by name
# TODO review if this makes sense
around  BUILDARGS => sub {
    my $orig = shift;
	my $class = shift;
	if ( @_ == 1 && not ref $_[0] ) {
		return { name => $_[0] };
	} else {
		return &$orig($class,@_);
	}
};

sub add_node {
	my ($self,$node, %args) = @_;
    
    $self->log_debug("add_node called with $node");
    return if not defined $node; 
    my $name = $args{name} || $node->name;

	$node->parent($self);
	die unless defined ($node->does('MooseX::Fuse::Node'));
	$self->nodes->{$name} = $node;
	return $node;
}

sub get_node {
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
        return $child_node->get_node(join "/", @$paths);
    }
    else {
        $self->log_debug("found node and returning it");
		return $child_node;
	}
}


sub node_exists {
	my ($self, $node) = @_;
	return defined $self->get_node($node);
}

sub path_split {
	my ($self, $path) = @_;

	return wantarray ? ("/") : ["/"] if ($path eq "/") ;

	my @path = split /\//, $path;
#	unshift @path, "/";
	return wantarray ?  @path : \@path;
}

1;
