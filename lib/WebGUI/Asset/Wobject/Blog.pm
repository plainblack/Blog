package WebGUI::Asset::Wobject::Blog;

our $VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use warnings;
use strict;

use base qw(
    WebGUI::Asset::Wobject
    WebGUI::AssetAspect::Installable
);

use Tie::IxHash;
use WebGUI::International;
use WebGUI::User;

#-------------------------------------------------------------------

=head2 canPost ( [userId] )

Verifies group and user permissions to be able to post to the blog.

=head3 userid

Optional user id.  If not supplied, the current user is used.

=cut

sub canPost {
    my $self = shift;
    my $user = $self->userIdOrCurrent(shift);
    return $user->isInGroup( $self->get('groupIdPost') );
}

#-------------------------------------------------------------------

=head2 canReply ( [userId] )

Verifies group and user permissions to be able to reply to blog posts.

=head3 userid

Optional user id.  If not supplied, the current user is used.

=cut

sub canReply {
    my $self = shift;
    my $user = $self->userIdOrCurrent(shift);
    return $user->isInGroup( $self->get('groupIdReply') );
}

#-------------------------------------------------------------------

=head2 definition ( )

=cut

sub definition {
    my ( $class, $session, $definition ) = @_;
    my $i18n = WebGUI::International->new( $session, 'Asset_Blog' );

    tie my %properties, 'Tie::IxHash';
    %properties = (
        groupIdPost  => { fieldType => 'group' },
        groupIdReply => { fieldType => 'group' },
        viewTemplateId   => {
            fieldType => 'group',
            tab       => 'display',
            namespace => 'Blog/View',
        },
        postTemplateId => {
            fieldType => 'group',
            tab       => 'display',
            namespace => 'Blog/Post/View',
        },
        editPostTemplateId => {
            fieldType => 'group',
            tab       => 'display',
            namespace => 'Blog/Post/Edit',
        },
    );

    foreach my $p ( keys %properties ) {
        my $field = $properties{$p};
        $field->{label}     = $i18n->get("$p label");
        $field->{hoverHelp} = $i18n->get("$p description");
    }

    my %def = (
        assetName         => $i18n->get('assetName'),
        autoGenerateForms => 1,
        tableName         => 'Blog',
        className         => __PACKAGE__,
        properties        => \%properties,
    );

    push @$definition, \%def;
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 posts ( )

Returns an arrayref of all the blog posts for this blog asset.

=cut

sub posts {
    my $self = shift;
    return $self->getLineage(
        ['children'], {
            returnObjects => 1,
            isa           => 'WebGUI::Asset::BlogPost',
        },
    );
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new( $self->session, $self->get('viewTemplateId') );
    $template->prepare( $self->getMetaDataAsTemplateVariables );
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 userIdOrCurrent ( [userId] )

Returns a user object for the user id (if passed) or the session's current
user.

=head3 userid

Optional user id.  If not supplied, the current user is used.

=cut

sub userIdOrCurrent {
    my $self    = shift;
    my $session = $self->session;
    if ( my $userId = shift ) {
        return WebGUI::User->new( $session, $userId );
    }
    return $session->user;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self = shift;
    my $var  = $self->viewTemplateVariables;

    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
}

#-------------------------------------------------------------------

=head2 viewTemplateVariables ( )

Returns the template vars for the www_view method

=cut

sub viewTemplateVariables {
    my $self  = shift;
    my $var   = $self->get;
    my @posts = map { { 
        variables => $_->viewTemplateVariables, 
        content => $_->view 
    } } @{ $self->posts } ;
    $var->{posts} = \@posts;
    return $var;
}

1;

#vim:ft=perl
