package WebGUI::Asset::BlogPost;

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

use base qw(
    WebGUI::Asset::Wobject
    WebGUI::AssetAspect::Installable
);

use Tie::IxHash;
use base 'WebGUI::Asset';
use WebGUI::Utility;

# To get an installer for your wobject, add the Installable AssetAspect
# See WebGUI::AssetAspect::Installable and sbin/installClass.pl for more
# details

=head1 NAME

Package WebGUI::Asset::BlogPost

=head1 DESCRIPTION

Provides capability create and edit blog posts

=head1 SYNOPSIS

use WebGUI::Asset::BlogPost;


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 canEdit ( )

Need to reference Blog for 

=cut

sub canEdit {
    my $self = shift;
    my $userId = shift || $self->session->user->userId;
    if ($userId eq $self->get("ownerUserId")) {
        return 1;
    }
    my $user = WebGUI::User->new($self->session, $userId);
    return $self->SUPER::canEdit($userId)
        || $self->getBlog>canPost($userId);
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for New Asset instances.  You absolutely need 
this method in your new Assets. 

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, "Asset_BlogPost" );
    tie my %properties, 'Tie::IxHash', (
	content=> {
            fieldType    => "HTMLArea",
            defaultValue => '',
        },
    );
    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'blogpost.gif',
        autoGenerateForms => 1,
        tableName         => 'BlogPost',
        className         => 'WebGUI::Asset::BlogPost',
        properties        => \%properties,
	autoGenerateForm=>0,
        };
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 duplicate

This method exists for demonstration purposes only.  The superclass
handles duplicating NewAsset Assets.  This method will be called 
whenever a copy action is executed

=cut

sub duplicate {
    my $self     = shift;
    my $newAsset = $self->SUPER::duplicate(@_);
    return $newAsset;
}

#-------------------------------------------------------------------

=head2 getBlog (  )

Returns the parent Blog for this Post.  Cache the entry for speed.

=cut

sub getBlog {
    my $self = shift;
    if (!$self->{_blog}) {
        $self->{_blog} = $self->getParent;
    }
    return $self->{_blog};
}

#-------------------------------------------------------------------

=head2 getEditForm (  )

Returns a templated form for adding or editing Stories.

=cut

sub getEditForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_BlogPost');
    my $form    = $session->form;
    my $blog = $self->getBlog;
    my $isNew   = $self->getId eq 'new';
    my $url     = $isNew ? $blog->getUrl : $self->getUrl;
    my $title   = $self->getTitle;
    my $var     = {
        formFooter     => WebGUI::Form::formFooter($session),
        formTitle      => $isNew
                        ? $i18n->get('add a post','Asset_BlogPost')
                        : $i18n->get('editing','Asset_BlogPost').' '.$title,
        titleForm      => WebGUI::Form::text($session, {
                             name  => 'title',
                             value => $form->get('title')    || $self->get('title'),
                          } ),
        contentForm      => WebGUI::Form::HTMLArea($session, {
                             name  => 'content',
                             value => $form->get('content')    || $self->get('content'),
                          } ),
        keywordsForm      => WebGUI::Form::text($session, {
                             name  => 'keywords',
                             value => $form->get('keywords')    || $self->get('keywords'),
                          } ),
        saveButton     => WebGUI::Form::submit($session, {
                            name  => 'savePost',
                            value => $i18n->get('save post'),
                          }),
    };
    if ($isNew) {
        $var->{formHeader} .= WebGUI::Form::hidden($session, { name => 'assetId', value => 'new' })
                           .  WebGUI::Form::hidden($session, { name => 'class',   value => $form->process('class', 'className') });
    }
    else {
        $var->{formHeader} .= WebGUI::Form::hidden($session, { name => 'url',     value => $url});
    }
    return $self->processTemplate($var, $blog->get('editPostTemplateId'));

}

#-------------------------------------------------------------------

=head2 indexContent ( )

Extend base class to index BlogPost content

=cut

sub indexContent {
    my $self    = shift;
    my $indexer = $self->SUPER::indexContent;
    $indexer->addKeywords($self->get('content'), );
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = $self->getBlog->get('postTemplateId');
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  Do custom things with
noFormPost fields here, or do whatever you want.  This method is called
when /yourAssetUrl?func=editSave is requested/posted.

=cut

sub processPropertiesFromFormPost {
    my $self = shift;
    $self->SUPER::processPropertiesFromFormPost;
}

#-------------------------------------------------------------------

=head2 purge ( )

This method is called when data is purged by the system.
removes collateral data associated with a NewAsset when the system
purges it's data.  This method is unnecessary, but if you have 
auxiliary, ancillary, or "collateral" data or files related to your 
asset instances, you will need to purge them here.

=cut

sub purge {
    my $self = shift;
    return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

sub purgeRevision {
    my $self = shift;
    return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;    
    my $var = $self->viewTemplateVariables();
    return $self->processTemplate($var,undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 viewTemplateVariables ( $var )

Add template variables to the existing template variables.  This includes asset level variables.

=head3 $var

Template variables will be added onto this hash ref.

=cut

sub viewTemplateVariables {
    my ($self)  = @_;
    my $session = $self->session;    
    my $blog = $self->getBlog;
    my $var     = $self->get;

    $var->{canEdit}     = $self->canEdit;
    return $var;
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page.  Unless the method needs
special handling or formatting, it does not need to be included in
the module.

Overridden because the standard, autogenerated form is not used.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;
    return $session->privilege->locked()       unless $self->canEditIfLocked;
    return $self->getBlog->processStyle($self->getEditForm);
}

#-------------------------------------------------------------------

=head2 www_view

Override www_view from asset because BlogPosts inherit a style template from
the Blog Archive that contains them.

=cut

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess unless $self->canView;
	$self->session->http->sendHeader;
	$self->prepareView;
	return $self->getBlog->processStyle($self->view);
}


1;

#vim:ft=perl
