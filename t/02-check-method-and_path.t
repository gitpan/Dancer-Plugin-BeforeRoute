use strict;
use warnings;
use t::TestApp;
use Dancer::Test;
use Test::More tests => 4;

response_content_is [ GET  => "/" ]    => "homepage";
response_content_is [ GET  => "/foo" ] => "foo";
response_content_is [ GET  => "/foo/baz" ] => "baz";
response_content_is [ POST => "/bar" ] => "bar";
