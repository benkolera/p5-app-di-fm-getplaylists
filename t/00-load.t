#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::DiFm::GetPlaylists' ) || print "Bail out!\n";
}

diag( "Testing App::DiFm::GetPlaylists $App::DiFm::GetPlaylists::VERSION, Perl $], $^X" );
