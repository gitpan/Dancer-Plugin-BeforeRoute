use strict;
use warnings;

package Dancer::Plugin::BeforeRoute;
{
  $Dancer::Plugin::BeforeRoute::VERSION = '0.71';
}
use Carp "confess";
use Dancer ":syntax";
use Dancer::Plugin;

my %BEFORE_COLLECTIONS = ();
my $SETUP_ALL_HOOK     = 0;

register before_route => sub {
    before_of( before => @_ );
};

register before_of => sub {
    my $hook_name = _hook_name( before => shift );
    my ( $path, $subref, @methods ) = _args(@_);
    my $collection_ref = _collection($hook_name);
    push @$collection_ref,
      {
        methods => \@methods,
        path    => $path,
        subref  => $subref,
      };
};

register request_for => sub {
    my $hook = shift
      or confess "dev: Missing hook name";
    my $path = shift
      or confess "dev: Missing route path";
    my @methods = @_
      or confess "dev: Missing methods";

    my $request_method = request->method;
    my $request_path   = request->path_info;

    grep {
        info(   "$hook is trying to match "
              . qq{'$request_method $request_path'}
              . qq{against '$_ $path'} )
    } @methods;

    return if !_is_the_right_method( $request_method, @methods );
    return if !_is_the_right_path( $request_path, $path );

    info "--> got 1";

    return 1;
};

## Only run once setup the hooks
hook before => \&_setup_before_route_hooks;

sub _hook_name {
    my $prefix = shift;
    my $name   = shift
      or confess "dev: missing hook name\n";
    return $name =~ m/^$prefix/
      ? $name
      : $prefix . "_" . $name;
}

sub _args {
    my $methods = shift
      or confess "dev: missing method\n";

    my @methods = ref $methods ? @$methods : ($methods);

    my $path = shift
      or confess "dev: missing path\n";
    my $subref = shift
      or confess "dev: missing a subref -> [[ @methods: $path ]]\n";

    return ( $path, $subref, @methods );
}

sub _is_the_right_method {
    my $method  = shift;
    my @methods = shift;
    return ( grep { /^\Q$method\E$/i } @methods ) ? 1 : 0;
}

sub _is_the_right_path {
    my $got_path      = shift;
    my $expected_path = shift;
    if ( ref $expected_path ) {
        return $got_path =~ /$expected_path/ ? 1 : 0;
    }
    if ( $expected_path =~ /\:/ ) {
        $expected_path =~ s/\:[^\/]+/[^\/]+/g;
        return $got_path =~ /$expected_path/ ? 1 : 0;
    }
    return $got_path eq $expected_path ? 1 : 0;
}

sub _collection {
    my $hook_name = shift
      or confess "dev: missing hook name";
    $BEFORE_COLLECTIONS{$hook_name} ||= [];
}

sub _setup_before_route_hooks {
    ## Just return at second time
    return if $SETUP_ALL_HOOK;

    ## Run at first time
    foreach my $hook_name ( keys %BEFORE_COLLECTIONS ) {
        my $collection_ref = _collection($hook_name);
        hook $hook_name => sub {
            _scan_routes_and_execute( $hook_name, \@_, @$collection_ref );
        }
    }

    $SETUP_ALL_HOOK = 1;
}

sub _scan_routes_and_execute {
    my $hook_name = shift
      or confess "dev: Missing hook name";
    my $args   = shift;
    my @routes = @_;

  ROUTE:
    foreach my $route (@routes) {
        next ROUTE
          if !request_for( $hook_name, $route->{path}, @{ $route->{methods} } );
        $route->{subref}->(@$args);
    }
}

register_plugin;

__END__
=head1 NAME
 
Dancer::Plugin::BeforeRoute - A before hook for a specify route or routes
  
=head1 SYNOPSIS

 use Dancer::Plugin::BeforeRoute;

 before_route get => "/", sub {
     var before_run => "homepage";
 };

 get "/" => sub {
     ## Return "homepage"
     return var "before_run";
 };

 ## Only for GET /foo
 before_route get => "/foo", sub {
     var before_run => "foo"
 };

 ## Only for GET /foo
 before_for template_render => get => "/foo" => sub {
     my $stash = shift;
     $stash->{foo} = "bar"; 
 };

 get "/foo" => sub {
     ## Return "foo"
     return var "before_run";
 };

=head1 DESCRIPTION

Dancer provides hook before to do everythings before going any route.

This plugin is to provide a little bit more specifically hook before route or route(s) executed.

=head1 AUTHOR
 
Michael Vu, C<< <micvu at cpan.org> >>
 
=head1 BUGS
 
Please report any bugs or feature requests to C<bug-dancer-plugin-beforeroute at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer::Plugin::BeforeRoute>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.
 
=head1 SUPPORT
 
You can find documentation for this module with the perldoc command.
 
    perldoc Dancer::Plugin::BeforeRoute
 
You can also look for information at:
 
=over 4
 
=item * RT: CPAN's request tracker
 
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Plugin-BeforeRoute>
 
=item * AnnoCPAN: Annotated CPAN documentation
 
L<http://annocpan.org/dist/Dancer-Plugin-BeforeRoute>
 
=item * CPAN Ratings
 
L<http://cpanratings.perl.org/d/Dancer-Plugin-BeforeRoute>
 
=item * Search CPAN
 
L<http://search.cpan.org/dist/Dancer-Plugin-BeforeRoute>
 
=item * GIT Respority
 
L<https://bitbucket.org/mvu8912/p5-dancer-plugin-beforeroute>
 
=back
 
=head1 ACKNOWLEDGEMENTS
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

