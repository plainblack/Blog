#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

$|++; # disable output buffering
our ($webguiRoot, $configFile, $help, $man);

BEGIN {
    $webguiRoot = "/data/WebGUI";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Pod::Usage;
use Getopt::Long;
use WebGUI::Session;

# Get parameters here, including $help
GetOptions(
    'configFile=s'  => \$configFile,
    'help'          => \$help,
    'man'           => \$man,
);

pod2usage( verbose => 1 ) if $help;
pod2usage( verbose => 2 ) if $man;
pod2usage( msg => "Must specify a config file!" ) unless $configFile;  

my $session = start( $webguiRoot, $configFile );

addArchives($session);


finish($session);

sub addArchives {
    my $session = shift;
    $session->db->write("create table assetAspectArchives (assetId char(22) binary not null, revisionDate bigint not null, archivesTemplateId char(22) binary not null default 'archives00000000000001' ,primary key (assetId,revisionDate))");
}

#----------------------------------------------------------------------------
# Your sub here

#----------------------------------------------------------------------------
sub start {
    my $webguiRoot  = shift;
    my $configFile  = shift;
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->set({name => 'Name Your Tag'});
    #
    ##
    
    return $session;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->commit;
    ##
    
    $session->var->end;
    $session->close;
}

__END__


=head1 NAME

utility - A template for WebGUI utility scripts

=head1 SYNOPSIS

 utility --configFile config.conf ...

 utility --help

=head1 DESCRIPTION

This WebGUI utility script helps you...

=head1 ARGUMENTS

=head1 OPTIONS

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--help>

Shows a short summary and usage

=item B<--man>

Shows this document

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

#vim:ft=perl
