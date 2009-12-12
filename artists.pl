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
		"* ".
	"FROM ".
		"mus_artist a ";
$query .= "Where ". $where if $where;
$query .= " ORDER BY ".
	"lower(nname)";

my $head = "mus_artist: ";
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
print start_table(), Tr( [ th( [ "albums", "titles", @col ]) ]);

while( $sth->fetch ){
	if( ! (++ $r % 100) ){
		print end_table(), start_table();
	}

	print "<tr>",
		td( a({href=>"albums.pl?q=artist_id=".$row{id}}, "albums")),
		td( a({href=>"titles.pl?q=t.artist_id=".$row{id}}, "titles"));
	foreach my $c( @col ){
		print td( $row{$c} );
	}
	print "</tr>";
}

print end_table(),p, "rows: ", $r;

$sth->finish;

