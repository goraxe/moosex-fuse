use Test::More qw(tests  4);

use strict;
use warnings;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use_ok('MooseX::Fuse::Node',"can use MooseX::Fuse::Node");
use_ok('MooseX::Fuse::Dir',"can use MooseX::Fuse::Dir");
use_ok('MooseX::Fuse::File',"can use MooseX::Fuse::File");
use_ok('MooseX::Fuse', "can use MooseX::Fuse");
#use_ok('MooseX::Fuse::DNS', "can use MooseX::Fuse::DNS");


#done_testing;
