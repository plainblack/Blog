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
use WebGUI::Exception;
use WebGUI::Asset;

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

} #addPingbackHttpHeader

#-------------------------------------------------------------------

=head2 definition (session, definition)

Extends the definition to add the comments and averageCommentRating fields.

=cut

sub definition {
    my ($class, $session, $definition) = @_;

#TODO:
#    my $i18n = WebGUI::International->new($session, q{Asset_});

    my %properties;
    tie %properties, q{Tie::IxHash};

    %properties = (
        pingbackTemplateId => {
            fieldType       => q{teamplate},
            defaultValue    => q{...}, # TODO
        },
        pingbackLinks => {
            noFormPost	    => 0,
            fieldType       => q{url},
            defaultValue    => q{},
        },
    );
    push(@{$definition}, {
        autoGenerateForms   => 1,
        tableName           => 'assetAspectPingback',
        className           => 'WebGUI::AssetAspect::Pingback',
        properties          => \%properties
    });

    return $class->next::method($session, $definition);
} #definition

#-------------------------------------------------------------------

=head2 getPingbackLinksTemplateVariables ()

Returns a list of template variables to be used with renderPingbackLinks().

=cut

sub getPingbackLinksTemplateVariables {

} #getPingbackLinksTemplateVariables

#-------------------------------------------------------------------

=head2 renderPingbackLinks ()

Renders the pingbackTemplateId template populated with data from getPingbackLinksTemplateVariables().

=cut

sub renderPingbackLinks {

} #renderPingbackLinks

#-------------------------------------------------------------------

=head2 www_pingback()

Handles an XML-RPC pingback.ping method.

=cut

sub www_pingback {

} #www_pingback

#-------------------------------------------------------------------

1;
