package MooseX::Fuse;

#use strict;
#use warnings;

#use base 'Fuse::Node';


use Moose;

use MooseX::Fuse::Dir;
use MooseX::Fuse::File;

use POSIX qw(ENOENT);

#use MooseX::Types;
use MooseX::Fuse::Types;
use MooseX::Types::Path::Class qw(Dir File);

use Log::Log4perl qw(:easy);

with 'MooseX::Log::Log4perl::Easy';
with 'MooseX::Fuse::Node';

BEGIN {
    Log::Log4perl->easy_init();
}


use Fuse;

has mountpoint => (
    is         => 'ro',
    isa        => Dir,
    required   => 1,
    coerce     => 1,
);

has '+type' => (
    default => S_IFDIR
);


has '+name' => (
	default => '/' ,
);


sub BUILD {
    my ($self ) = @_;
    $self->add_node($self); #, {name => '/' });
}

sub mount {
    my ($self) = @_;

    Fuse::main(
          mountpoint    => $self->mountpoint,
          getdir        => sub { $self->getdir(@_); },
          getattr       => sub { $self->getattr(@_); },
          statfs        => sub { $self->statfs(@_); },
          open          => sub { $self->open(@_); },
          read          => sub { $self->read(@_); },
    );
}

sub getdir {
    my ($self, $dir) = @_;
    $self->log_debug("getdir called with: $dir");
}

sub getattr {
    my ($self, $file) = @_;
    $self->log_debug("get attr called with: $file");
    my $node = $self->get_node($file);
    return -ENOENT() unless defined $node;
    # else return the files stat
    return $node->stat;
}

sub statfs {
    my ($self) = @_;
    $self->log_debug("statfs called");
}

sub open {
    my ($self, $file) = @_;
    $self->log_debug("open called with file: $file");
}

sub read {
    my ($self, $file) = @_;
    $self->log_debug("read called with file: $file");

}

sub create_path {
	my $self = shift;
	my $path = shift;
	my @parts = split /\//, $path;

	my $node = $self;
	warn "attempting to create path for $path";
	foreach my $dir (@parts) {
		$dir = "/" if ($dir eq "");
		if ($node->get_node($dir)){
			warn "got existing node $dir";
			$node = $node->get_node($dir);

		} else {
			warn "creating new node $dir";
			my $dd = Fuse::Dir->new(
				name=>$dir, 
				perms=> $self->{umask}
			);
			$node = $node->add_node($dd);
		}
	}
	return $node;
}

sub path_exists {
	my $self = shift;
	my $path = shift;

	my @parts = split /\//, $path;
	my $node = $self->nodes;
	while (my $dir = shift @parts) {
		return unless $node->get_node($dir);
		$node = $node->get_node($dir);
	}
	return $node;
}



no Moose;
1;
