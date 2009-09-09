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

my $class     = 'WebGUI::Asset::Wobject::Blog';
my $postClass = 'WebGUI::Asset::BlogPost';
my $session   = WebGUI::Test->session;

my $home = WebGUI::Asset->getDefault($session);
my $tag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($tag);

my ($posters, $rubes, $repliers) = 
    map { my $g = WebGUI::Group->new($session, 'new');
          WebGUI::Test->groupsToDelete($g); 
          $g } (1..3);

my ($andy, $red, $brooks, $boggs) =
    map { my $u = WebGUI::User->new($session, 'new');
          $u->username($_);
          WebGUI::Test->usersToDelete($u);
          $u; } qw(andy red brooks boggs);

sub addToGroups {
    my ($group, @users) = @_;
    my $ids = [ map { $_->userId } @users ];
    $group->addUsers($ids);
}

addToGroups($posters, $andy, $red);
addToGroups($rubes, $boggs, $brooks);
addToGroups($repliers, $red, $brooks);

my $blog = $home->addChild(
    {
        className    => $class,
        groupToPost  => $posters->getId,
        groupToReply => $repliers->getId,
    }
);

my $postPermissions = WebGUI::Test::Maker::Permission->new();
$postPermissions->prepare(
    {
        object => $blog,
        method => 'canPost',
        pass   => [ $andy, $red ],
        fail   => [ $boggs, $brooks ],
    }
);

my $replyPermissions = WebGUI::Test::Maker::Permission->new();
$replyPermissions->prepare(
    {
        object => $blog,
        method => 'canReply',
        pass   => [ $red, $brooks ],
        fail   => [ $andy, $boggs ],
    }
);

#----------------------------------------------------------------------------
# Tests

my $testCount = 5 + $replyPermissions->plan + $postPermissions->plan;
plan tests => $testCount;

#----------------------------------------------------------------------------
# put your tests here

use_ok($class);
isa_ok($blog, $class, "addChild");
$postPermissions->run();
$replyPermissions->run();

my $firstPost = $blog->addChild(
    {
        className => $postClass,
        title     => 'The first time I laid eyes on Andy Dufresne',
        content   => 'I knew I would like him.',
    }
);

isa_ok($firstPost, $postClass, 'First!');

my $secondPost = $blog->addChild(
    {
        className => $postClass,
        title     => 'Two things never happened after that',
        content   => 'The sisters never messed with Andy again...',
    }
);

isa_ok($secondPost, $postClass, 'Second!');

my $var = $blog->viewTemplateVariables;
my $got = {
    posts => $var->{posts}
};
my $expected = {
    posts => [
        {
            content => $firstPost->view,
            variables => $firstPost->viewTemplateVariables,
        },
        {
            content => $secondPost->view,
            variables => $secondPost->viewTemplateVariables,
        },
    ]
};
cmp_deeply($got, $expected, 'template vars');

#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
