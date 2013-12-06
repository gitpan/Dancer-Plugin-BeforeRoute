=head1 NAME
 
Dancer::Plugin::BeforeRoute - Run something before a specific route run
  
=head1 SYNOPSIS

 use Dancer::Plugin::BeforeRoute;

 before_route get => "/", sub {
     var before_home => 1;
 };

 get "/" => sub {
     ## Return 1
     return var "before_home";
 };

 get "/foo" => sub {
     ## Return nothing
     return var "before_home";
 };

=head1 DESCRIPTION

Most developers add lines of if-else to do something in before sub before run a path.

Or some people has lot of before hook with duplicated code to check path to run before running a path.

But I think we can do it better, No big sub and no duplication checks. Use this plugin please!:)

Tell me if you have a better idea.

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
  $Dancer::Plugin::BeforeRoute::VERSION = '0.2';
}
use Dancer ":syntax";
use Dancer::Plugin;

register before_route => sub {
    my $methods = shift
        or die "dev: missing method";
    my $path = shift
        or die "dev: missing path";
    my $subref = shift
        or die "dev: missing a subref";

    my @methods = ref $methods ? @$methods : ($methods);

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
