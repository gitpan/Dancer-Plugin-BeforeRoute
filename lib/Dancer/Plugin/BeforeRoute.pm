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

 before_route get => "/foo", sub {
     var before_run => "foo"
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

package Dancer::Plugin::BeforeRoute;
{
  $Dancer::Plugin::BeforeRoute::VERSION = '0.3';
}
use Carp "confess";
use Dancer ":syntax";
use Dancer::Plugin;

register before_route => sub {
    my $methods = shift
        or confess "dev: missing method\n";

    my @methods = ref $methods ? @$methods : ($methods);

    my $path = shift
        or confess "dev: missing path\n";
    my $subref = shift
        or confess "dev: missing a subref -> [[ @methods: $path ]]\n";

    hook before => sub {
        my $request_method = request->method;
        if ( !_is_the_right_method( request->method, @methods ) ) {
            return;
        }
        if ( !_is_the_right_path( request->path_info, $path ) ) {
            return;
        }
        $subref->();
    };
};

sub _is_the_right_method {
    my $method  = shift;
    my @methods = shift;
    return ( grep {/^\Q$method\E$/i} @methods ) ? 1 : 0;
}

sub _is_the_right_path {
    my $got_path      = shift;
    my $expected_path = shift;
    if ( ref $expected_path ) {
        return $got_path =~/$expected_path/ ? 1 : 0;
    }
    if ( $expected_path =~/\:/ ) {
        $expected_path =~s/\:[^\/]+/[^\/]+/g;
        return $got_path =~/$expected_path/ ? 1 : 0;
    }
    return $got_path eq $expected_path ? 1 : 0;
}

register_plugin;
