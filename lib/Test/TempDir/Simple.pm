package Test::TempDir::Simple;

use strict;
use warnings;

our $VERSION = '0.03';

use Cwd qw/abs_path/;
use File::Temp qw/tempdir/;
use File::Copy::Recursive qw/dircopy/;

BEGIN {
    my $dir = '';

    sub initdir() {
        File::Copy::Recursive::pathrm($dir, 1) if -d $dir;
        $dir = tempdir(TMPDIR => 1, CLEANUP => 1);
        $dir;
    }

    sub testdir() { $dir }

    my %switches = (
        t   => 1,
        dir => 1
    );

    do {
        my $caller  = caller;
        no strict 'refs';
        no warnings 'redefine';
        *{"${caller}::testdir"} = \&testdir;
        *{"${caller}::initdir"} = \&initdir;
    };

    sub import {
        my $pacakge = shift;
        my @path;
        my %enable;
        while (my $arg = shift) {
            if ((my $a = $arg) =~ s{^-}{}) {
                if ($switches{$a}) {
                    if ($a eq 'dir') {
                        $enable{dir} = shift || '';
                    }
                    else {
                        $enable{$a}++;
                    }
                }
            }
            else {
                push @path, $arg;
            }
        }
        my $path_prefix = '';
        if ($enable{t}) {
            unless ($INC{'FindBin.pm'}) {
                require 'FindBin.pm';
                FindBin->import;
            }
            my @p = split "/", "$FindBin::Bin";
            while (my $d = pop @p) {
                last if $d eq 't';
            }
            $path_prefix = join '/', @p;
        }
        elsif ($enable{dir}) {
            $path_prefix = $enable{dir};
        }
        for my $path (@path) {
            my $apath = abs_path("${path_prefix}/${path}");
            my $d = (split '/', $apath)[-1];
            print "[path copy] $apath\n";
            dircopy($apath, "${dir}/${d}") if -d $apath;
        }
    }

    initdir();
};

=head1 NAME

Test::TempDir::Simple - 任意のディレクトリを一時ディレクトリに展開

=head1 SYNOPSIS

    # if test code
    use Test::TempDir::Simple -t => @dirs;

    # else
    use Test::TempDir::Simple -dir => '/path/to/dir', @dirs;

=head1 DESCRIPTION

ファイルに書き出す系のコード等をテストする際、
指定したディレクトリをテスト環境用にコピーします。

=over 2

=item testdir

生成した一時ディレクトリのパスを返却

=item initdir

生成した一時ディレクトリを削除し、新たに作成しなおす

=back

=head1 SEE ALSO

L<File::Temp>, L<File::Copy::Recursive>

=head1 AUTHOR

taiyoh E<lt>sun.basix@gmail.com<gt>

=cut

1;

