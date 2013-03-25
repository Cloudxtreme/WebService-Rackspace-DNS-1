#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WebService::Rackspace::DNS' ) || print "Bail out!\n";
}

diag( "Testing WebService::Rackspace::DNS $WebService::Rackspace::DNS::VERSION, Perl $], $^X" );
