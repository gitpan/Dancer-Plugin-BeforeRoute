package t::TestApp;

use Dancer;
use Dancer::Plugin::BeforeRoute;

before_route get => "/", sub {
    var before_run => "homepage";
};

get "/" => sub {
    ## Return "homepage"
    return var "before_run";
};

before_route get => "/foo", sub {
    var before_run => "foo"
};

get "/foo" => sub {
    ## Return "foo"
    return var "before_run";
};

before_route post => qr{/bar}, sub {
    ## Retrun "bar"
    return var before_run => "bar";
};

post "/bar" => sub {
    return var "before_run";
};

before_route get => "/foo/:bar", sub {
    ## Retrun "bar"
    return var before_run => param "bar";
};

get "/foo/:bar" => sub {
    return var "before_run";
};

1;
