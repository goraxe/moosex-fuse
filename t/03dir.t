
use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Moose;

use Log::Log4perl;

BEGIN {
	Log::Log4perl->easy_init();
}


use FindBin qw($Bin);
use lib qq($Bin/../lib);

use_ok('MooseX::Fuse::Dir',"can use MooseX::Fuse::Dir");


{ # define test package
	package t::Fuse::Dir;
		use Moose;
		with 'MooseX::Fuse::Dir';
		no Moose;
	1;
}

{ # check interface
	my $dir = t::Fuse::Dir->new(name=>'test');

	does_ok($dir, "MooseX::Fuse::Dir", "created a dir");

	# test that these methods are present
	can_ok($dir, qw(children add remove get));
}

{ # test methods

	my $n1 = t::Fuse::Dir->new("/");
	does_ok($n1, 'MooseX::Fuse::Node', "dir has Node role");
	does_ok($n1, 'MooseX::Fuse::Dir', "dir has Dir role");
	is ($n1->name, "/", "name correctly set");

	my $n2 = t::Fuse::Dir->new("subdir");
	# add first node to 2nd node
	my $n3 = $n1->add($n2);
	is($n3,$n2, "correct node returned");

	# check we had add as child
	my $n4 = $n1->get("subdir");
	
	is($n4, $n2, "has sub directory");
}

1;

