use strict;
use warnings;

use Test::More tests=>5;
use Test::Moose;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use_ok('MooseX::Fuse::Node','use module MooseX::Fuse::Node');


{
	package Test::Fuse::Node;
		use Moose;
		with 'MooseX::Fuse::Node';
		no Moose;
	1;

}


my $n1 = Test::Fuse::Node->new(name=>"root");

# create a node
does_ok($n1, 'MooseX::Fuse::Node', "created a node");

# create another node
my $n2 = Test::Fuse::Node->new("subdir");

# create a node
does_ok($n2, 'MooseX::Fuse::Node', "created a node");

# add first node to 2nd node
my $n3 = $n1->add_node($n2);
is_deeply($n3,$n2, "correct node returned");

# check we had add as child
ok($n1->get_node("subdir"), "has sub directory");
