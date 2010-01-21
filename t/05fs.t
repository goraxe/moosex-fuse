use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Moose;
use POSIX ":sys_wait_h";
use FindBin qw($Bin);
use lib qq($Bin/../lib);

use_ok('MooseX::Fuse',"can use MooseX::Fuse");

my $mnt = "$Bin/mnt";

my $fs = MooseX::Fuse->new(mountpoint => $mnt);

isa_ok($fs,"MooseX::Fuse", "Fuse Object Created");

does_ok($fs, "MooseX::Fuse::Node", "Fs object is also a node");

my $root = $fs->get_node("/");
is($root, $fs, "root element points to fs object");

#ok($fs->create_path("/test1"), "create new directory");

my $pid = fork();
die "could not fork for test mount: $!" if ($pid == -1);

if ($pid == 0) {
    close STDIN;
    ok($fs->mount());
    close STDERR;
    close STDOUT;
    exit 0;
} 

sleep 1;

ok(-e $mnt, "file stat okay");
ok(-d $mnt, "file system mounted");

system("fusermount -u $mnt");

waitpid $pid, WNOHANG;
