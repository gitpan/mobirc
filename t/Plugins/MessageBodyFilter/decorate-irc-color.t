use t::Utils;
use App::Mobirc;

use Test::Base::Less;
use Test::Requires 'String::IRC';

global_context->load_plugin( { module => 'MessageBodyFilter::IRCColor', config => { no_decorate => 0} } );

filters {
    input => ['eval', \&decorate_irc_color],
};

sub decorate_irc_color {
    my $x = shift;
    ($x,) = global_context->run_hook_filter('message_body_filter', $x);
    return $x;
}

run {
    my $block = shift;
    is($block->input, $block->expected);
};
done_testing;

__END__

===
--- input: String::IRC->new('world')->yellow('green')
--- expected: <span style="color:yellow;background-color:green;">world</span>

===
--- input: String::IRC->new('world')->red('green')
--- expected: <span style="color:red;background-color:green;">world</span>

===
--- input: String::IRC->new('world')->red('green')->bold;
--- expected: <span style="font-weight:bold;color:red;background-color:green;">world</span>

=== inverse is nop.because, html cannot use inverse.
--- input: String::IRC->new('world')->inverse
--- expected: world

===
--- input: String::IRC->new('world')->underline
--- expected: <span style="text-decoration:underline;">world</span>

