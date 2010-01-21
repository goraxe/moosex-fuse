
use strict;
use warnings;

use Test::More tests =>2;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use_ok('MooseX::Fuse::Dir',"can use MooseX::Fuse::Dir");


my $dir = MooseX::Fuse::Dir->new(name=>'test');

isa_ok($dir, "MooseX::Fuse::Dir", "created a dir");


