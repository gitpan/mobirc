package App::Mobirc::Plugin::Authorizer::DoCoMoGUID;
use strict;
use MooseX::Plaggerize::Plugin;
use Carp;
use App::Mobirc::Util;
use HTML::StickyQuery::DoCoMoGUID;
use App::Mobirc::Validator;

has docomo_guid => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

hook authorize => sub {
    my ( $self, $global_context, $req, ) = validate_hook('authorize', @_);

    my $subno = $req->header('x-dcmguid');
    if ( $subno && $subno eq $self->docomo_guid ) {
        DEBUG "SUCESS AT DocomoGUID";
        return true;
    } else {
        return false;
    }
};

hook 'html_filter' => sub {
    my ($self, $global_context, $req, $content) = validate_hook('html_filter', @_);

    DEBUG "Filter DoCoMoGUID";
    return ($req, $content) unless $req->mobile_agent->is_docomo;
    return ($req, HTML::StickyQuery::DoCoMoGUID->new()->sticky( scalarref => \$content, ));
};

1;
