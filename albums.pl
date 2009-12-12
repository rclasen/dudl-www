#!/usr/bin/perl -w

#
# Copyright (c) 2008 Rainer Clasen
#
# This program is free software; you can redistribute it and/or modify
# it under the terms described in the file LICENSE included in this
# distribution.
#

use strict;
use Dudl::DB;
use CGI qw( :standard *table );

my $where = param( 'q' );
my $dudl = new Dudl::DB;
my $db = $dudl->db;

my $query =
	"SELECT ".
		"a.id, ".
		"a.artist_id as aa_id, ".
		"aa.nname as a_artist, ".
		"a.album, ".
		"a.publish_date ".
	"FROM ".
		"mus_album a, ".
		"mus_artist aa ".
	"WHERE ".
		"a.artist_id=aa.id ";
$query .= "AND ". $where if $where;
$query .= " ORDER BY ".
	"lower(aa.nname), ".
	"lower(a.album)";

my $head = "mus_albums: ";
$head .= $where if $where;

print header,
	start_html($head),
	h1($head),
	start_form,
	"where: ", textfield(
		-name=>'q',
		-default=>$where,
		-override=>1,
		-size=>80,
	),p,
	submit,
	end_form, p;

my $sth = $db->prepare( $query );
if( ! $sth ){
	print $db->errstr ."\nquery: $query\n";
	exit 1;
}

my $res = $sth->execute;
if( ! $res ){
	print $sth->errstr ."\nquery: $query\n";
	exit 1;
}

my @col = @{$sth->{NAME_lc} };
my %row;
$sth->bind_columns( \( @row{ @col } ));

my $r = 0;
print start_table(), Tr( [ th( [ qw(titles files id artist album) ]) ]);

while( $sth->fetch ){
	if( ! (++ $r % 100) ){
		print end_table(), start_table();
	}

	print "<tr>",
		td( a({href=>"titles.pl?q=album_id=".$row{id}}, "titles")),
		td( a({href=>"files.pl?album=".$row{id}}, "files"));
	foreach my $c( @col ){
		if( $c eq "aa_id" ){
		} elsif( $c eq "a_artist" ){
			print td( a({href=>"artists.pl?q=id=".$row{aa_id}},
				$row{$c}));
		} else {
			print td( $row{$c} );
		}
	}
	print "</tr>";
}

print end_table(),p, "rows: ", $r;

$sth->finish;

