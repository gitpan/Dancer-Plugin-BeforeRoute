use strict;
use warnings;
use lib "t/lib";
use TestApp;
use Dancer::Test;
use Test::More tests => 9;

response_content_is [ GET => "/" ]    => "homepage";
response_content_is [ GET => "/foo" ] => "foo",
    "Test string path";
response_content_is [ GET => "/foo/baz" ] => "baz",
    "Test token path";
response_content_is [ POST => "/bar" ] => "bar",
    "Test regexp";
response_status_is [ POST => "/baz" ] => 404,
    "Not found";
response_content_is [GET => "/index.html" ] => "foobar = yes\n";
response_content_is [GET => "/second.html" ] => "foo = yes\n";

response_content_is [GET => "/admin/login" ] => 1;
response_content_is [POST => "/admin/login" ] => 1;
