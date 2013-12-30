use strict;
use warnings;
use Dancer::Plugin::BeforeRoute;

use Test::More tests => 2;                      # last test to print

ok _setup() , "Run at first name";
is _setup(), undef, "Not running at second time";

sub _setup {
    return Dancer::Plugin::BeforeRoute::_setup_before_route_hooks();
}
