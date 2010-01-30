use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Moose;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use_ok('MooseX::Fuse::Node','use module MooseX::Fuse::Node');


{
	package t::Fuse::Node;
		use Moose;
		with 'MooseX::Fuse::Node';
		no Moose;
	1;

}


my $n1 = t::Fuse::Node->new(name=>"root");

# create a node
does_ok($n1, 'MooseX::Fuse::Node', "created a node");

# create another node
my $n2 = t::Fuse::Node->new("subdir");

# create a node
does_ok($n2, 'MooseX::Fuse::Node', "created a node");

