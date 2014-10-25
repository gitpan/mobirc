use strict;
use warnings;
use App::Mobirc::Plugin::HTMLFilter::CompressHTML;
use Test::Base;
use App::Mobirc;

my $global_context = App::Mobirc->new(
    {
        httpd  => { lines => 40 },
        global => { keywords => [qw/foo/] }
    }
);
$global_context->load_plugin( 'HTMLFilter::CompressHTML' );

filters {
    input => [qw/compress/],
};

run_is input => 'expected';

sub compress {
    my $html = shift;
    my $c = undef;
    ($c, $html) = $global_context->run_hook_filter('html_filter', $c, $html);
    $html;
}

__END__

===
--- input
<h1>foo</h1>
<!-- comment -->
<div class="bar">
    yeah
</div>
--- expected
<h1>foo</h1>
<div class="bar">
yeah
</div>
