package WebGUI::AssetAspect::TopKeywords;

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
use Tie::IxHash;
use WebGUI::Exception;
use WebGUI::Keyword;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::AssetAspect::TopKeywords

=head1 DESCRIPTION

This is an aspect which will display the top keywords associated with the asset's descendants.

=head1 SYNOPSIS

 use Class::C3;
 use base qw(WebGUI::AssetAspect::TopKeywords WebGUI::Asset);
 
And then where-ever you would call $self->SUPER::someMethodName call $self->next::method instead.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition

Extends the definition to add the comments and averageCommentRating fields.

=cut

sub definition {
	my $class      = shift;
	my $session    = shift;
	my $definition = shift;
    my $i18n       = WebGUI::International->new($session,"Asset_DataForm");

	tie my %properties, 'Tie::IxHash';

	%properties = (
		topKeywordsToDisplay   => {
			fieldType       => "integer",
			defaultValue    => 50,
			tab             => "properties",
			label           => $i18n->get("topKeywordsToDisplay label"),
            hoverHelp       => $i18n->get("topKeywordsToDisplay hoverhelp"),
			},
		topKeywordsListTemplate => {
			fieldType       => "template",
			defaultValue    => "",
			namespace       => "AssetAspect/TopKeywords/List",
			tab             => "display",
			label           => $i18n->get("topKeywordsListTemplate label"),
            hoverHelp       => $i18n->get("topKeywordsListTemplate hoverhelp"),
            afterEdit       => 'func=edit',
			},
		topKeywordsKeywordTemplate => {
			fieldType       => "template",
			defaultValue    => "",
			namespace       => "AssetAspect/TopKeywords/List",
			tab             => "display",
			label           => $i18n->get("topKeywordsKeywordTemplate label"),
            hoverHelp       => $i18n->get('topKeywordsKeywordTemplate hoverHelp'),
            afterEdit       => 'func=edit',
			},
		);

	push(@{$definition}, {
		autoGenerateForms   => 1,
		tableName           => 'assetAspectTopKeywords',
		properties          => \%properties
		});
	return $class->next::method($session, $definition);
}

#-------------------------------------------------------------------

=head2 getTopKeywordsList ()

Returns a list of the top N keywords for the descendants of this asset along with the number of children associated with that keyword.

=cut

sub getTopKeywordsList {
	my $self     = shift;
	my $session  = $self->session;
	my $keywords = WebGUI::Keyword->new($session);

	return $keywords->getTopKeywords({
		asset  => $self,
		limit  => $self->get("topKeywordsToDisplay"),
	});
}


1;

