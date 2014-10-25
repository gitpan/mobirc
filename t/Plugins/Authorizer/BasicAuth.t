use strict;
use warnings;
use Test::More tests => 2;
use App::Mobirc;
use App::Mobirc::Plugin::Authorizer::BasicAuth;
use MIME::Base64 ();
use HTTP::Engine::Compat::Context;

my $mobirc = App::Mobirc->new(
    {
        httpd  => { lines => 40 },
        global => { keywords => [qw/foo/] }
    }
);
$mobirc->load_plugin( {module => 'Authorizer::BasicAuth', config => {username => 'dankogai', password => 'kogaidan'}} );

ok !$mobirc->run_hook_first('authorize', create_c('dankogai', 'dankogai'));
ok $mobirc->run_hook_first('authorize', create_c('dankogai', 'kogaidan'));

sub create_c {
    my ($user, $passwd) = @_;
    my $c = HTTP::Engine::Compat::Context->new;
    $c->req->header('Authorization' => 'Basic ' . MIME::Base64::encode("$user:$passwd", ''));
    $c;
}

