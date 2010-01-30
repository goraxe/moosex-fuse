# vim: et
package MooseX::Fuse;

#use strict;
#use warnings;

#use base 'Fuse::Node';


use Moose;

with 'MooseX::Fuse::Dir';
#use MooseX::Fuse::File;

use POSIX qw(ENOENT);

#use MooseX::Types;
use MooseX::Fuse::Types;
use MooseX::Types::Path::Class qw(Dir File);

use Log::Log4perl qw(:easy);

use Data::Dumper;

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
    default => sub {  return S_IFDIR;}
);


has '+name' => (
	default => '/' ,
);


#sub BUILD {
#    my ($self ) = @_;
#    $self->add_node($self); #, {name => '/' });
#}

sub mount {
    my ($self) = @_;

    Fuse::main(
          mountpoint    => $self->mountpoint,
          getdir        => sub { $self->get_dir(@_); },
          getattr       => sub { $self->get_attr(@_); },
          statfs        => sub { $self->statfs(@_); },
          open          => sub { $self->open(@_); },
          read          => sub { $self->read(@_); },
    );
    return 1;
}

sub get_dir {
    my ($self, $dir) = @_;
    $self->log_debug("getdir called with: $dir");
    my $node = $self->get_node($dir);
    # for the moment special case . and ..
    return ('.', '..', $node->children); # unless $self->has_nodes();
}

sub get_node {
    my ($self, $path) = @_;
    $self->log_debug("get_node called with: $path");
    my @paths = $self->path_split($path);

    # handle special case where looking for root element
    if (@paths == 1 ) {
        $self->log_debug("get_node returning self ($self)");
        return $self;
    } 

    my $node = $self;
    shift @paths; # remove leading /
    # walk the tree 
    foreach my $p (@paths) {
        $node = $node->get($p);
    }
    $self->log_debug("get_node returning node " . ( defined $node ? $node->name() : " not found ") );
    return $node;
}

sub get_attr {
    my ($self, $file) = @_;
    $self->log_debug("get attr called with: $file");

    my $node = $self->get_node($file);
    return -ENOENT() unless defined $node;
    # else return the files stat
    $self->log_debug("returning node stat " . Dumper($node->stat));
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


sub path_split {
	my ($self, $path) = @_;

	return wantarray ? ("/") : ["/"] if ($path eq "/") ;

	my @path = split /\//, $path;
#	unshift @path, "/";
	return wantarray ?  @path : \@path;
}

no Moose;
1;
