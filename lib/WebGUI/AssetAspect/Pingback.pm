package WebGUI::AssetAspect::Pingback;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Class::C3;
use JSON;
use XML::RPC;

use WebGUI::Exception;
use WebGUI::Asset;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::AssetAspect::Pingback

=head1 DESCRIPTION

This is an aspect which addes Pingback support to assets.

=head1 SYNOPSIS

 use Class::C3;
 use base qw(WebGUI::AssetAspect::Pingback WebGUI::Asset);

And then where-ever you would call $self->SUPER::someMethodName call $self->next::method instead.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addPingbackHttpHeader ()

Adds the pingback header to the current output.

=cut

sub addPingbackHttpHeader {
    my ($self) = @_;

    my $session = $self->session();

    # hmm... is there API to set header values?
    my ($request, $url) = $session->quick(q/request url/);

    $request->headers_out->set(
        q{X-Pingback},
        $url->gateway($self->getUrl(), q{func=pingback}),
    );

    return;
} #addPingbackHttpHeader

#-------------------------------------------------------------------

=head2 definition (session, definition)

Extends the definition to add the comments and averageCommentRating fields.

=cut

sub definition {
    my ($class, $session, $definition) = @_;

#TODO:
#    my $i18n = WebGUI::International->new($session, q{Asset_Aspect_Pingback});

    my %properties;
    tie %properties, q{Tie::IxHash};

    %properties = (
        'pingbackTemplateId' => {
            'fieldType'       => q{template},
            'defaultValue'    => q{pingback00000000000001},
            'namespace'       => q{asset-aspect-pingback},
        },
        'pingbackLinks' => {
            'noFormPost'      => 0,
            'fieldType'       => q{url},
            'defaultValue'    => q{},
        },
    );
    push(@{$definition}, {
        'autoGenerateForms'   => 1,
        'tableName'           => 'assetAspectPingback',
        'className'           => 'WebGUI::AssetAspect::Pingback',
        'properties'          => \%properties
    });

    return $class->next::method($session, $definition);
} #definition

#-------------------------------------------------------------------

=head2 getPingbackLinksTemplateVariables ()

Returns a list of template variables to be used with renderPingbackLinks().

=cut

sub getPingbackLinksTemplateVariables {
    my ($self) = @_;


    my %vars = (
        'pingbackLinks.loop' => $self->_getPingbackLinks(),
    );

    return \%var;
} #getPingbackLinksTemplateVariables

#-------------------------------------------------------------------

=head2 renderPingbackLinks ()

Renders the pingbackTemplateId template populated with data from getPingbackLinksTemplateVariables().

=cut

sub renderPingbackLinks {
    my ($self) = @_;

    my $session = $self->session();
    my $templateId = $self->get(q{pingbackTemplateId});
    my $template = WebGUI::Asset::Template->new($session, $templateId);

    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            'error'      => qq{Template not found},
            'templateId' => $templateId,
            'assetId'    => $self->getId(),
        );
    }

    return $template->process($self->getPingbackLinksTemplateVariables());
} #renderPingbackLinks

#-------------------------------------------------------------------

=head2 www_pingback()

Handles an XML-RPC pingback.ping method.

=cut

sub www_pingback {
    my ($self) = @_;

    my $session = $self->session();
    my $xmlrpc = XML::RPC->new();
    my $xml    = $self->process('POSTDATA');

    $session->http()->setMimeType(q{text/xml});

    return $xmlrpc->receive(
        $xml, sub {
            my ($methodname, @params) = @_;

            my ($source, $target) = @params;

            # only catch pingback.ping
            return 0 if $methodname ne q{pingback.ping};

            # For now, minimal verification only.
            return 16 if ! (defined $source && $source ne q{});
            return 33 if ! (defined $target && $target ne q{});


            # Verify target
            my $myUrl = $self->getUrl();
            if ($target !~ /$myUrl/) {

                $session->errorHandler()->debug(qq{Rejecting pingback target [$target]. My URL [$myUrl]});

                return 33;
            }


            my $links = $self->_getPingbackLinks();

            # already registerd
            return 48 if isIn($source, @$links);

            push @$links, $source;

            $self->_setPingbackLinks($links);

            # No error. Return a string confirming specifications:
            #   If the pingback request is successful, then the return
            #   value MUST be a single string, containing as much
            #   information as the server deems useful. This string
            #   is only expected to be used for debugging purposes.
            return qq{XML sucks! Use JSON instead!};
        },
    );
} #www_pingback

#-------------------------------------------------------------------

sub _getPingbackLinks {
    my ($self) = @_;

    my $links = [];
    eval {
        $links = JSON->new->decode($self->get(q{pingbackLinks}) || q{[]});
    };
    if ($@) {
        $self->session()->errorHandler()->error(qq{PingbackLinks cannot be decoded: $@});

        $links = [];
    }
    return $links;
} #_getPingbackLinks

#-------------------------------------------------------------------

sub _setPingbackLinks {
    my ($self, $links) = @_;

    $self->{'pingbackLinks'} = JSON->new->encode($links);

    return;
} #_getPingbackLinks

#-------------------------------------------------------------------

1;
