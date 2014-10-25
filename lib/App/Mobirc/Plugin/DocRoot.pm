package App::Mobirc::Plugin::DocRoot;
use strict;
use MooseX::Plaggerize::Plugin;
use App::Mobirc::Util;
use XML::LibXML;
use Encode;
use Params::Validate ':all';

has root => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

hook request_filter => sub {
    my ($self, $global_context, $c) = validate_pos(@_,
        { isa => __PACKAGE__ },
        { isa => 'App::Mobirc' },
        { isa => 'HTTP::Engine::Compat::Context' },
    );

    my $root = $self->root;
    $root =~ s!/$!!;

    my $path = $c->req->uri->path;
    $path =~ s!^$root!!;
    $c->req->uri->path($path);
};

hook response_filter => sub {
    my ($self, $global_context, $c) = @_;

    if ($c->res->redirect) {
        DEBUG "REWRITE REDIRECT : " . $c->res->redirect;

        my $root = $self->root;
        $root =~ s!/$!!;
        $c->res->redirect( $root . $c->res->redirect );

        DEBUG "FINISHED: " . $c->res->redirect;
    }
};

hook html_filter => sub {
    my ($self, $global_context, $c, $content, ) = @_;

    DEBUG "FILTER DOCROOT";
    DEBUG "CONTENT IS UTF* : " . Encode::is_utf8($content);

    my $root = $self->root;
    $root =~ s!/$!!;

    my $doc = eval { XML::LibXML->new->parse_html_string($content) };
    if ($@) {
        warn "$content, orz.\n $@";
        return ($c, $content);
    }
    for my $elem ($doc->findnodes('//a')) {
        if (my $href = $elem->getAttribute('href')) {
            if ($href =~ m{^/}) {
                $elem->setAttribute(href => $root . $href);
            }
        }
    }
    for my $elem ($doc->findnodes('//form')) {
        if (my $uri = $elem->getAttribute('action')) {
            if ($uri =~ m{^/}) {
                $elem->setAttribute(action => $root . $uri);
            }
        }
    }
    for my $elem ($doc->findnodes('//link')) {
        $elem->setAttribute(href => $root . $elem->getAttribute('href'));
    }
    for my $elem ($doc->findnodes('//script')) {
        if ($elem->hasAttribute('src')) {
            $elem->setAttribute(src => $root . $elem->getAttribute('src'));
        }
    }

    my $html = $doc->toStringHTML;
    $html =~ s{<!DOCTYPE[^>]*>\s*}{};

    return ($c, decode($doc->encoding || "UTF-8", $html));
};

1;
__END__

=head1 NAME

App::Mobirc::Plugin::DocRoot - rewrite document root

=head1 SYNOPSIS

    - module: App::Mobirc::Plugin::DocRoot
      config:
        root: /foo/

=head1 DESCRIPTION

rewrite path.

=head1 AUTHOR

Tokuhiro Matsuno

=head1 SEE ALSO

L<App::Mobirc>

