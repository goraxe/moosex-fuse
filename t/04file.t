use strict;
use warnings;

use Test::More tests =>1;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use_ok('MooseX::Fuse::File',"can use MooseX::Fuse::File");
