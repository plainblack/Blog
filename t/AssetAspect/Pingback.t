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

# This script tests Pingback aspect.
#
#

use FindBin;
use strict;
use lib "/data/WebGUI/t/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::AssetAspect::Pingback');

#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
