use strict;
use warnings;
use App::Mobirc;
use HTTP::MobileAgent;
use HTTP::Engine::Context;
use Test::Base;
use HTTP::Engine middlewares => [
    '+App::Mobirc::Web::Middleware::MobileAgent'
];

my $global_context = App::Mobirc->new(
    {
        httpd  => { lines => 40 },
        global => { keywords => [qw/foo/] }
    }
);
$global_context->load_plugin( 'HTMLFilter::ConvertPictograms' );

filters {
    input => [qw/yaml convert/],
};

sub convert {
    my $x = shift;
    my $c = HTTP::Engine::Context->new;
    $c->req->user_agent( $x->{ua} );
    ($c, $x->{src}) = $global_context->run_hook_filter( 'html_filter', $c, $x->{src} );
    return $x->{src};
}

__END__

===
--- input
ua: Vodafone/1.0/V904SH/SHJ001/SN123456789012 Browser/VF-NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1
src: "&#xE63E;&#xE65C;"
--- expected: &#xE04A;&#xE434;

===
--- input
ua: KDDI-SA31 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0
src: "&#xE63E;&#xE65C;"
--- expected: <img localsrc="44" /><img localsrc="341" />

