package Test::TempDir::Simple;

use strict;
use warnings;

our $VERSION = '0.01';

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
            my @p = reverse split "/", "$FindBin::Bin";
            my @t_path;
            while (my $d = shift @p) {
                last if $d eq 't';
            }
            $path_prefix = join '/', reverse @p;
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

1;
