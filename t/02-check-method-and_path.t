use Test::More tests => 14;
use strict;
use warnings;
use Dancer::Plugin::BeforeRoute;

my @before_routes = (
    [get => "/"],
    [[qw(get post)] => qr{^/teacher/.+}],
    [[qw(put del)] => qr{^/student/.+}],
    ["post" => "/something/:foo/:bar"],
);

my @requests = (
    {
        route => [get => "/"],
        expected => 1,
    },
    {
        route => [get => "/teacher"],
        expected => 0,
    },
    {
        route => [get => "/teacher/"],
        expected => 0,
    },
    {
        route => [post => "/teacher/something"],
        expected => 1,
    },
    {
        route => [get => "/teacher/something/1"],
        expected => 1,
    },
    {
        route => [put => "/teacher/something/1"],
        expected => 0,
    },
);


foreach my $request ( @requests ) {
    my $request_method = $request->{route}[0];
    my $request_path = $request->{route}[1];
    my $expected_result = $request->{expected};

    foreach my $rule ( @before_routes ) {
        my @expected_methods = _deref_arrayref( $rule->[0] );
        my $expected_path = $rule->[1];

        my $test_method = Dancer::Plugin::BeforeRoute::_is_the_right_method( $request_method, @expected_methods );
        my $test_path   = Dancer::Plugin::BeforeRoute::_is_the_right_path( $request_path, $expected_path );

        my $got_result = $test_method && $test_path;

        if ( $got_result eq $expected_result ) {
            is $got_result, $expected_result, "$request_method: $request_path against($expected_result) [@expected_methods] => $expected_path";
        }
    }
}

sub _deref_arrayref {
    my $data = shift;
    return ref $data ? @$data : ($data);
}

