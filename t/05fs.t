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
does_ok($fs, "MooseX::Fuse::Dir", "Fs object is also a dir");

is_deeply( [$fs->children()], [ ] );



#ok($fs->create_path("/test1"), "create new directory");
my $pid = fork();
die "could not fork for test mount: $!" if ($pid == -1);

if ($pid == 0) {

subtest "mount filesystem" => sub {
    plan tests => 1;
    close STDIN;
    pass("mount");
my $builder = Test::More->builder;
#my $child = $builder->child("mount filesystem");
$builder->finalize();
    $fs->mount();
    close STDERR;
    close STDOUT;

#$child->finalize();
    exit 0;
    }
} 

sleep 1;
#exit;
#ok(system ("ls $mnt"), "can see inside dir");
ok(-e $mnt, "file stat okay");
ok(-d $mnt, "file system mounted");

#my $builder = Test::More->builder;
#my $child = $builder->child("mount filesystem");
#$child->finalize();

system("fusermount -u $mnt");

waitpid $pid, WNOHANG;

