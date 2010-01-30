package MooseX::Fuse::Node;

#use Moose;
use Moose::Role;

with 'MooseX::Log::Log4perl::Easy';

use Carp qw(croak carp);
use POSIX qw(ENOENT);
use Data::Dumper;

#use constant {
#	S_IFMT  => 0170000,
#	S_IFSOCK=> 0140000,
#	S_IFLNK => 0120000,
#	S_IFREG => 0100000,
#	S_IFBLK => 0060000,
#	S_IFDIR => 0040000,
#	S_IFCHR => 0020000,
#	S_IFIFO => 0010000,
#	S_ISUID => 0004000,
#	S_ISGID => 0002000,
#	S_ISVTX => 0001000,
#};

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
#	isa	=>	'Int',
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
	default	=> sub { time()-1000 }
);

has 'mtime' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=> sub { time()-1000 }
);

has 'ctime' => (
	is	=>	'ro',
	isa	=>	'Int',
	default	=> sub { time()-1000 }
);

has 'size' => (
	is	=>	'rw',
	isa	=>	'Int',
	default	=>	0
);

has mode => (
    is => 'rw',
    isa => 'Int',
    default => 755,
);


has modes => (
    is  => 'ro',
    lazy_build => 1,
);


sub _build_modes {
    my ($self) = @_;
    $self->log_debug("type is " . $self->type . " type << 9 is " .
        ($self->type << 9) . " mode is " . $self->mode . " final result is " . (($self->type << 9) + $self->mode));
    return ($self->type << 9) + $self->mode;
}


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




1;
