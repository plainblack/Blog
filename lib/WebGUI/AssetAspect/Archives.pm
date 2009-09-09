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

=head2 definition

Extends the definition to add the comments and averageCommentRating fields.

=cut

sub definition {
    my $class, $session, $definition = @_;
    tie my %properties, 'Tie::IxHash';
    %properties = (
        archivesTemplateId => {
            fieldType       => "template",
            defaultValue    => 'archives00000000000001', 
            namespace       => 'asset-aspect-archives',
            },
        );
    push(@{$definition}, {
        autoGenerateForms   => 1,
        tableName           => 'assetAspectArchives',
        className           => 'WebGUI::AssetAspect::Archives',
        properties          => \%properties
        });
    return $class->next::method($session, $definition);
}

#-------------------------------------------------------------------

=head2 getArchivesMonthsForYear ( year )

Returns a sorted hashreference of archive months for a given year, and the number of assets in each month.

=head3 year

The year to get the list of months for.

=cut

sub getArchivesMonthsForYear {
	my ($self, $yearToMatch) = @_;
	my $session = $self->session;
    my $date = $session->datetime;
    my $nextAsset = $self->getLineageIterator(["descendants"],{returnObjects=>1});
    my %months = ();
    while (my $asset = $nextAsset->()) {
        my $year = $date->epochToHuman($asset->get('creationDate'), "%y");
        next unless $year eq $yearToMatch;
        my $month = $date->epochToHuman($asset->get('creationDate'), "%c");
        $months{$month}++;
    }   
    tie my %sortedMonths, 'Tie::IxHash';
    my @monthKeys = sort keys %sortedMonths;
    foreach my $month (@monthKeys) {
        $sortedMonths{$month} = $months{$month};
    }
    return \%sortedMonths;
}



#-------------------------------------------------------------------

=head2 getArchivesItemsForMonth ( month, year )

Returns a sorted hashreference of archives items (the descendants of the parent this aspect is attached to).

=head3 month

The month to limit the scope.

=head3 year

The year to limit the scope.

=cut

sub getArchivesItemsForMonth {
	my ($self, $monthToMatch, $yearToMatch) = @_;
	my $session = $self->session;
    my $date = $session->datetime;
    my $nextAsset = $self->getLineageIterator(["descendants"],{returnObjects=>1});
    tie my %items, 'Tie::IxHash';
    while (my $asset = $nextAsset->()) {
        my $year = $date->epochToHuman($asset->get('creationDate'), "%y");
        next unless ($year eq $yearToMatch);
        my $month = $date->epochToHuman($asset->get('creationDate'), "%c");
        next unless ($month eq $monthToMatch);
        $items{$asset->getUrl} = $asset->getTitle;
    }   
    return \%items;
}



#-------------------------------------------------------------------

=head2 getArchivesYears ( )

Returns a sorted hashreference of archives years and the number of assets in each year.

=cut

sub getArchivesYears {
	my ($self) = @_;
	my $session = $self->session;
    my $date = $session->datetime;
    my $nextAsset = $self->getLineageIterator(["descendants"],{returnObjects=>1});
    my %years = ();
    while (my $asset = $nextAsset->()) {
        my $year = $date->epochToHuman($asset->get('creationDate'), "%y");
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


