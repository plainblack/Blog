# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "/data/WebGUI/t/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Maker::Permission;
use WebGUI::User;
use WebGUI::Group;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

my $blogPost = 'placeholder for Test::Maker::Permission';
my $wgBday = WebGUI::Test->webguiBirthday;

my $canPostGroup = WebGUI::Group->new($session, 'new');
my $postUser = WebGUI::User->create($session);
$canPostGroup->addUsers([$postUser->userId]);
my $blogOwner = WebGUI::User->create($session);
my $reader       = WebGUI::User->create($session);
$postUser->username('Can Post User');
$reader->username('Average Reader');
$blogOwner->username('Blog Owner');
WebGUI::Test->groupsToDelete($canPostGroup);
WebGUI::Test->usersToDelete($postUser, $blogOwner, $reader);

my $canEditMaker = WebGUI::Test::Maker::Permission->new();
$canEditMaker->prepare({
    object   => $blogPost,
    session  => $session,
    method   => 'canEdit',
    pass     => [3, $postUser, $blogOwner ],
    fail     => [1, $reader ],
});

my $defaultNode = WebGUI::Asset->getDefault($session);
my $blog     = $defaultNode->addChild({
    className   => 'WebGUI::Asset::Wobject::Blog',
    title       => 'Blog',
                   #1234567890123456789012
    assetId     => 'TestBlogAsset1',
    groupToPost => $canPostGroup->getId,
    ownerUserId => $blogOwner->userId,
});
my $blogTag  = WebGUI::VersionTag->getWorking($session);
$blogTag->commit;
WebGUI::Test->tagsToRollback($blogTag);

#----------------------------------------------------------------------------
# Tests

my $tests = 16;
plan tests => 1
            + $tests
            + $canEditMaker->plan
            ;

my $class  = 'WebGUI::Asset::BlogPost';
my $loaded = use_ok($class);

SKIP: {

skip "Unable to load module $class", $tests unless $loaded;

############################################################
#
# validParent
#
############################################################

ok(! WebGUI::Asset::BlogPost->validParent($session), 'validParent: no session asset');
$session->asset($defaultNode);
ok(! WebGUI::Asset::BlogPost->validParent($session), 'validParent: wrong type of asset');
$session->asset(WebGUI::Asset->getRoot($session));
ok(! WebGUI::Asset::BlogPost->validParent($session), 'validParent: Any old folder is not valid');
$session->asset($blog);
ok(  WebGUI::Asset::BlogPost->validParent($session), 'validParent: Blog is valid');

############################################################
#
# Make a new one.  Test defaults
#
############################################################

$blogPost = $blog->addChild({
    className => 'WebGUI::Asset::BlogPost',
    title     => 'Post 1',
    content  => 'The story of a CMS',
    keywords    => 'keyword1 keyword2',
});

isa_ok($blogPost, 'WebGUI::Asset::BlogPost', 'Created a BlogPost asset');
is($blogPost->get('isHidden'), 1, 'by default, stories are hidden');
$blogPost->update({isHidden => 0});
is($blogPost->get('isHidden'), 1, 'stories cannot be set to not be hidden');
$blogPost->requestAutoCommit;

############################################################
#
# getBlog
#
############################################################

is($blogPost->getBlogPost->getId, $blog->getId, 'getBlog gets the parent blog for the BlogPost');

###############################################
#
# editTemplateVariables
#
############################################################

my $templateVariables = $blogPost->editTemplateVariables ;
isa_ok($templateVariables->{titleForm},'WebGUI::Form::text','editTemplateVariables provides BlogPost title field') ;
isa_ok($templateVariables->{contentForm},'WebGUI::Form::HTMLArea','editTemplateVariables provides BlogPost content field') ;
isa_ok($templateVariables->{keywordsForm},'WebGUI::Form::text','editTemplateVariables provides BlogPost keywords field') ;
isa_ok($templateVariables->{saveButton},'WebGUI::Form::submit','editTemplateVariables provides BlogPost keywords field') ;

###############################################
#
# viewTemplateVariables
#
############################################################

$templateVariables = $blogPost->viewTemplateVariables ;
is($templateVariables->{title},'Post 1','viewTemplateVariables provides BlogPost title') ;
is($templateVariables->{content},'The story of a CMS','viewTemplateVariables provides BlogPost content') ;
is($templateVariables->{keywords},'keyword1 keyword2','viewTemplateVariables provides BlogPost keywords') ;

}

#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
