use strict;
use Test::More;
use FindBin;

BEGIN { use_ok 'Test::TempDir::Simple' };

my $dir = testdir;

ok $dir, "$dir created";

ok !`ls $dir`, "ls $dir nothing";

Test::TempDir::Simple->import(-t => qw/dirtest/);

ok -d "$dir/dirtest", "$dir/dirtest exists";
ok -e "$dir/dirtest/hoge", "$dir/dirtest/hoge exists";

Test::TempDir::Simple->import(
    -dir => $FindBin::Bin,
    'testdir'
);

ok -d "$dir/testdir", "$dir/testdir exists";
ok -e "$dir/testdir/fuga", "$dir/testdir/fuga exists";

my $dir2 = initdir();

ok !-d $dir, "$dir no longer exists";
ok -d $dir2, "$dir2 created";

done_testing;
