use strict;
use warnings;
use App::Mobirc;
use Test::More;
use HTTP::Engine::Compat::Context;
use HTTP::Engine::Compat middlewares => [
    '+App::Mobirc::Web::Middleware::MobileAgent'
];

eval q{ use HTTP::MobileAgent::Plugin::Locator };
plan skip_all => "HTTP::MobileAgent::Plugin::Locator is not installed." if $@;
plan tests => 2;

my $mobirc = App::Mobirc->new(
    {
        httpd => { lines => 40 },
        global => { keywords => [qw/foo/], stopwords => [qw/foo31/] },
    }
);
$mobirc->load_plugin({module => 'GPS', config => {}});

my $c = sub {
    my $c = HTTP::Engine::Compat::Context->new();
    $c->req->user_agent('DoCoMo/2.0 SH904i(c100;TB;W24H16)');
    $c->req->query_params(
        { lat => '35.21.03.342', lon => '138.34.45.725', geo => 'wgs84' } );
    $c;
  }
  ->();

$mobirc->run_hook_first('httpd', $c, '/channel/%23coderepos/gps_do');
is $c->res->status, 302;
is $c->res->redirect, '/channels/%23coderepos?msg=L:Lat%3A%2035.21.03.342%2C%20Lng%3A%20138.34.45.725';

