use inc::Module::Install;

name 'Test-TempDir-Simple';
license 'perl';
build_requires 'Test::More';

version_from 'lib/Test/TempDir/Simple.pm';

requires 'Cwd';
requires 'File::Copy::Recursive' => '0.38';
requires 'File::Temp' => '0.22';

#test_requires 'Test::More' => 0;

WriteAll;
