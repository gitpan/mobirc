package App::Mobirc::HTTPD::Handler;
use Moose;
use Scalar::Util qw/blessed/;
use App::Mobirc;
use App::Mobirc::Util;
use App::Mobirc::HTTPD::Router;
use App::Mobirc::HTTPD::C::Mobile;
use App::Mobirc::HTTPD::C::Ajax;
use App::Mobirc::HTTPD::C::Static;
use Data::Visitor::Encode;

my $dve = Data::Visitor::Encode->new;

sub handler {
    my $c = shift;

    for my $code (@{App::Mobirc->context->get_hook_codes('request_filter')}) {
        $code->($c);
    }

    if (authorize($c)) {
        my $response = process_request($c);
        if ($response && blessed $response && $response->isa('HTTP::Response')) { # TODO: remove this feature
            $c->res->set_http_response($response);
        }
        for my $code (@{App::Mobirc->context->get_hook_codes('response_filter')}) {
            $code->($c);
        }
    } else {
        $c->res->status(401);
        $c->res->header('WWW-Authenticate' => qq(Basic Realm="mobirc"));
    }
}

sub authorize {
    my $c = shift;
    for my $code (@{App::Mobirc->context->get_hook_codes('authorize')}) {
        if ($code->($c)) {
            DEBUG "AUTHORIZATION SUCCEEDED";
            return 1; # authorization succeeded.
        }
    }
    return 0; # authorization failed
}

sub process_request {
    my ($c, ) = @_;

    my $rule = App::Mobirc::HTTPD::Router->match($c->req);

    unless ($rule) {
        # hook by plugins
        for my $code (@{App::Mobirc->context->get_hook_codes('httpd')}) {
            my $finished = $code->($c, $c->req->uri->path);
            if ($finished) {
                # XXX we should use html filter?
                return;
            }
        }

        # doesn't match.
        do {
            my $uri = $c->req->uri->path;
            warn "dan the 404 not found: $uri" if $uri ne '/favicon.ico';
            # TODO: use $c->res->status(404)
            my $response = HTTP::Response->new(404);
            $response->content("Dan the 404 not found: $uri");
            return $response;
        };
    }

    my $controller = "App::Mobirc::HTTPD::C::$rule->{controller}";

    my $meth = $rule->{action};
    my $post_meth = "post_dispatch_$meth";
    my $get_meth  = "dispatch_$meth";
    my $args = $dve->decode( $c->req->mobile_agent->encoding, $rule->{args} );
    if ( $c->req->method =~ /POST/i && $controller->can($post_meth)) {
        return $controller->$post_meth($c, $args);
    } else {
        return $controller->$get_meth($c, $args);
    }
}

1;

