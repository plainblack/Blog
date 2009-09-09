package WebGUI::AssetAspect::Archives;

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
use WebGUI::Form;
use WebGUI::HTML;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::AssetAspect::Archives

=head1 DESCRIPTION

This is an aspect which allows you to add an interface to traverse descendant archives.

=head1 SYNOPSIS

 use Class::C3;
 use base qw(WebGUI::AssetAspect::Archives WebGUI::Asset);
 
And then where-ever you would call $self->SUPER::someMethodName call $self->next::method instead.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 getArchivesYears ( )

Returns a sorted hashreference of archives years and the number of assets in that year.

=cut

sub getArchivesYears {
	my ($self) = @_;
	my $session = $self->session;
    my $date = $session->datetime;
    my $nextAsset = $self->getLineageIterator(["descendants"],{returnObjects=>1});
    my %years = ();
    while (my $asset = $nextAsset->()) {
        my $year = $date->epochToHuman($asset->get('dateCreated'), "%y");
        $years{$year}++;
    }   
    tie my %sortedYears, 'Tie::IxHash';
    my @yearKeys = sort keys %sortedYears;
    foreach my $year (@yearKeys) {
        $sortedYears{$year} = $years{$year};
    }
    return \%sortedYears;
}



1;


