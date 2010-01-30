#
#===============================================================================
#
#         FILE:  Types.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gordon Irving (), <Gordon.irving@sophos.com>
#      COMPANY:  Sophos
#      VERSION:  1.0
#      CREATED:  19/01/10 23:16:58 GMT
#     REVISION:  ---
#===============================================================================
package MooseX::Fuse::Types;


use strict;
use warnings;

#use MooseX::Types -declare => [qw(
#    FuseNode
#:)];


use Sub::Exporter -setup => { exports => [
        qw(S_IFMT S_IFSOCK S_IFLNK S_IFREG S_IFBLK S_IFDIR S_IFCHR S_IFIFO S_ISUID S_ISGID S_ISVTX)
    ],
    groups => {
        types => [ qw(S_IFMT S_IFSOCK S_IFLNK S_IFREG S_IFBLK S_IFDIR S_IFCHR S_IFIFO S_ISUID S_ISGID S_ISVTX)],
        default => [ qw(-types) ],
    },
};

sub S_IFMT   { 170000 }
sub S_IFSOCK { 140000 }
sub S_IFLNK  { 120000 }
sub S_IFREG  { 0010 }
sub S_IFBLK  { 60000 }
sub S_IFDIR  { 0040 }
sub S_IFCHR  { 20000 }
sub S_IFIFO  { 10000 }
sub S_ISUID  { 4000 }
sub S_ISGID  { 2000 }
sub S_ISVTX  { 1000 }
1;
