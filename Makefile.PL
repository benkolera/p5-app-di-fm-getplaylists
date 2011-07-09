use inc::Module::Install;

name     'App-DiFm-GetPlaylists';
all_from 'lib/App/DiFm/GetPlaylists.pm';
author   q{Ben Kolera <ben.kolera@gmail.com>};
license  'perl';

build_requires 'Test::More';
requires 'JSON';
requires 'autodie';
requires 'WWW::Mechanize';
requires 'Getopt::Long';
requires 'Pod::Usage';

install_script 'di-fm-get_playlists.pl';

auto_install;

WriteAll;

