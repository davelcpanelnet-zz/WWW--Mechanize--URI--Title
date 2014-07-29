=head1 NAME

WWW::Mechanize::URI::Title - Perl module mechanism to grab URL titles. Intended for us with POE IRC services. Hand the PM a URL/URI and get back the title for even sights refusing content to LWP::UserAgent 

=head1 SYNOPSIS

  use WWW::Mechanize::URI::Title;
  my $url = 'http://www.example.link';
  my $uri_title = WWW:Mechanize::URI::Title:get_title($url);

=head1 DESCRIPTION

This is a very basic module that attempts to circumvent the latest attempts to curtail requests coming from LWP::UserAgent content requests.
Many sites now see reqeusts coming from LWP::UserAgent and will simply blackhole the requests which obviously prevent code bodies
such as URI::Title to come back empty with no title for the URI.  By leaning on WWW::Mechanize for the request and decoding from
HTML::Entities this code seems to be grabbing a good bit more titles.

The code is very simple and does attempt to parse out all of the cruft it can.  This logic will grow in future releases to 
remove more and more of the cruft we are seeing as websites change and adapt. 

=head1 AUTHOR

dawilan, E<lt>dave@thehhp.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by davelcpanelnet/dawilan

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.4 or,
at your option, any later version of Perl 5 you may have available.


=cut

package WWW::Mechanize::URI::Title;

use 5.014004;
use strict;
use warnings;

require Exporter;
use WWW::Mechanize;
use HTML::Entities;

## DEBUG
use Data::Dumper;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw( get_title );

our $VERSION = '0.001';

sub get_title {
    my $url = shift;

    my $mech = WWW::Mechanize->new();
    $mech->get( $url );

    my $trove = $mech->{content};
    $trove =~ tr/\r\n//d;
    $trove =~ s/\s{2,}/ /g;
    my @trove = split ( /\s/, $trove );

    my $title;
    foreach ( @trove ) {
        if ( /<title>/ .. /<\/title>/ ) {
            if ( $title ) {
                $title = $title . " " . $_;
            } else {
                $title = $_;
            }
	}
    }

    $title =~ s/^\s*//;
    $title =~ s/<\/?title>//g;
    $title =~ s/&raquo[;:]+|&laquo[;:]+/:/g;
    $title =~ s/^\s+[:;]+\s+//;
    $title =~ s/\s+$|^\s+//;
    $title =~ s/<\/?head>?//g;
    $title =~ s/<meta>?//g;
    $title =~ s/(\/>)?//g;
    $title =~ s/<!--//g;
    $title =~ s/charset="UTF-8">//g;

    return $title if $title;
    return 0;
}
